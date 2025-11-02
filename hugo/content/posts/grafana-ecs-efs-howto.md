---
title: "Grafana in ECS backed by EFS in terraform"
date: "2025-10-31"
author: "Tim Gibbon"
tags: ["ecs","efs","grafana","terraform","tofu", "fargate"]
keywords: ["ecs","efs","grafana","terraform","tofu","fargate"]
description : "Terraform Configuration to deploy Grafana based on ECS/Fargate/EFS/Route 53"
type: "post"
showTableOfContents: true
---

# Introduction

This blog post explains the technical implementation of Grafana on ECS backed by EFS via Terraform/Tofu, based on this [Github repository](https://github.com/tommybobbins/expert-octo-succotash). 

# Overview

This is a proof-of-concept for setting up Grafana cheaply, without using AWS Managed Grafana. It's designed to be cost effective using the native SQLite on a filesystem. Data sources, credentials and dashboards persist between container restarts. It generates a new VPC, with 3 public subnets, deploys an ECS cluster and EFS into those subnets. It then deploys the ECS service, mounting /var/lib/grafana onto the EFS to that the data persists container restarts.

![Grafana on ECS Backed by EFS](https://raw.githubusercontent.com/tommybobbins/expert-octo-succotash/refs/heads/main/images/Grafana-EFS-ECS.png)

# How It Works

ECS Fargate, running a Grafana container which makes a mount of an EFS filesystem at ```/var/lib/grafana```. This is where Grafana stores it's SQLite database and all persistent data. This allows the container to be restarted and any previous changes to be retained. 0.5 CPU is allocated and 2GB of RAM, this should be enough for Grafana provided that you are not creating too many alarms.

# IPv6 SNAFU

If IPv6 is enabled in the VPC, ECS will preferentially connect to the EFS IPv6 addresses. This will give an error similar to the following:

```
Task is stopping
ResourceInitializationError: failed to invoke EFS utils commands to set up EFS volumes: stderr: Mount attempt 1/3 failed due to timeout after 15 sec, wait 0 sec before next attempt. Mount attempt 2/3 failed due to timeout after 15 sec, wait 0 sec before next attempt. b'mount.nfs4: mount system call failed' Traceback (most recent call last): File "/usr/sbin/supervisor_mount_efs", line 52, in <module> return_code = subprocess.check_call(["mount", "-t", "efs", "-o", opts, args.fs_id_with_path, args.dir_in_container], shell=False) File "/usr/lib64/python3.9/subprocess.py", line 373, in check_call raise CalledProcessError(retcode, cmd) subprocess.CalledProcessError: Command '['mount', '-t', 'efs', '-o', 'noresvport', 'fs-03b924b6fb7476e29:/', '/efs-vols/grafana-db']' returned non-zero exit status 32. During handling of the above exception, another exception occurred: Traceback (most recent call last): File "/usr/sbin/supervisor_mount_efs", line 56, in <module> "message": err.message, : unsuccessful EFS utils comma
```

This error is because the VPC is IPv6 enabled, so the security groups and EFS also need to be considered. To fix this, EFS need to be dual (IPv4/IPv6) stacked and the Security Groups need to be adjusted to allow NFS on TCP port 2049.

# Grafana Permissions

Grafana needs to have the permission of /var/lib/grafana to be owned by UID 472, which can lead to a failure of the EFS mount if this is not the case. To avoid this, we've built an access point which sets the permissions correctly:

```
resource "aws_efs_access_point" "grafana" {
  file_system_id = aws_efs_file_system.grafana[0].id

  root_directory {
    path = "/grafana"

    creation_info {
      owner_gid   = 472
      owner_uid   = 472
      permissions = "775"
    }
  }
}
```

# Grafana Ubuntu Image

I wanted to use this because it's available outside of the Docker repository. I'm not linking to it here because I'm not sure I should be advertising it. This is a case of them respinning grafana, and placing the runtime in /app, with their own uids. I decided this was not worth the effort because it looks to be a Canonical NIH. I stuck with the standard Grafana image (I copied it to my own ECR repo to prevent Docker from rug pulling).

## Source Account Resources

- No prerequisites - it deploys a new VPC. 


