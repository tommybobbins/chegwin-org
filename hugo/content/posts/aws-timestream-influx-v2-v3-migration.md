---
title: "AWS Timestream for InfluxV2 to InfluxV3 migration"
date: "2025-11-04"
author: "Tim Gibbon"
tags: ["aws","timestream","influx","influxdb","influxdb3","migration","line protocol"]
keywords: ["aws","timestream","influx","influxdb","migration","line protocol"]
description : "Guide for migrating from AWS Managed influxv2 to influxv3"
type: "post"
showTableOfContents: true
---

# Howto Backup and Restore a Timestream for InfluxDB 2 database or migrate to InfluxDB 3

AWS announced the [availability](https://aws.amazon.com/about-aws/whats-new/2025/10/amazon-timestream-influxdb-3/) of Timestream for InfluxDB 3 on the 16th of October 2025. The documentation is currently limited and so migration options are not detailed. 

This guide explains one way to migrate the data between AWS Timestream for InfluxDBv2 to Timestream for InfluxDB 3 (or extract the data to any influx compatible database). I recommend that you check the data is consistent at every step.


## Overview

There are 6 steps to this process

- Build an InfluxDB 2 instance locally.
- Extract the AWS InfluxDB 2 database as a backup.
- Restore this database backup to the local instance.
- Use the influxd inspect command to extract the line protocol data
- Split this data into files smaller than 10MB.
- Write the line protocol data into the InfluxDB 3 instance 

## Build an InfluxDB instance locally.

This is slightly beyond the scope of the document, but follow the instructions https://docs.influxdata.com/influxdb/v2/get-started/ to install InfluxDB locally.

## Perform AWS InfluxDB 2 database as a backup.

Make sure you are connected to the remote database

```
$ influx config list
Active	Name		URL										Org
*	default		http://localhost:8086	bobbins
```
Oh dear, we are pointing to the local instance, we need to create a config for the remote instance.

```
$ influx config create --config-name prd1 --host-url https://randomprd1strings.timestream-influxdb.eu-west-2.on.aws:8086 --token <influxv2token> --org bobbins --active

Active	Name	URL										Org
*	prd1	https://randomprd1strings.timestream-influxdb.eu-west-2.on.aws:8086	bobbins
```
Now test the connection is good

```
$ influx v1 shell
```

## A Wrong turn, use a Token for the read/write configuration for the bucket.

This is not the right method, but included here for completeness. Skip ahead if you don't want to make the same mistake as me. 

Exit from it the shell and list the buckets

```
$ influx bucket list  
ID			Name		Retention	Shard group duration	Organization ID		Schema Type
0123456789a	data			8760h0m0s	168h0m0s		98754334221af	implicit
```
Backup the bucket locally to the current working directory:
```
$ influx backup --bucket-id 0123456789a . 
2025/10/31 14:58:20 WARN: Couldn't parse version "dev" reported by server, assuming latest backup/restore APIs are supported
2025/10/31 14:58:20 INFO: Downloading metadata snapshot
Error: failed to backup metadata: failed to download metadata snapshot: 401 Unauthorized: read:authorizations is unauthorized
```

## Use the AWS Secrets Manager to retrieve the username and password so we can perform the backup.

So that didn't work, we are using a bucket auth key and not the username and password that was used to create influxdb. We need to get the parameters from AWS SecretsManager:

    AWS Secrets Manager >> Secrets >> READONLY-InfluxDB-auth-parameters-abcdef174

```
$ influx config set -n prd1 --username-password myifluxadmin:mypassword
Active	Name	URL										Org
*	prd1	https://randomprd1string-timestream-influxdb.eu-west-2.on.aws:8086      bobbins	

$ influx bucket list
ID			Name			Retention	Shard group duration	Organization ID		Schema Type
ed1234456547	_monitoring		168h0m0s	24h0m0s			98754334211af	implicit
ab123445443f8	_tasks			72h0m0s		24h0m0s			98754334211af	implicit
0123456789a	bobbins-data			8760h0m0s	168h0m0s		98754334221af	implicit
```

Looking better, we can see _monitoring and _tasks. Backup will work.

## InfluxDB Backup

```
% influx backup --bucket-id 0123456789a .
2025/10/31 15:30:48 WARN: Couldn't parse version "dev" reported by server, assuming latest backup/restore APIs are supported
2025/10/31 15:30:48 INFO: Downloading metadata snapshot
2025/10/31 15:30:49 INFO: Backing up TSM for shard 1
2025/10/31 15:30:49 INFO: Backing up TSM for shard 2
2025/10/31 15:30:49 WARN: Shard 2 removed during backup
2025/10/31 15:30:49 INFO: Backing up TSM for shard 3
2025/10/31 15:30:49 WARN: Shard 3 removed during backup
2025/10/31 15:30:49 INFO: Backing up TSM for shard 4
2025/10/31 15:30:49 WARN: Shard 4 removed during backup
2025/10/31 15:30:49 INFO: Backing up TSM for shard 5
2025/10/31 15:30:49 INFO: Backing up TSM for shard 6
2025/10/31 15:30:49 INFO: Backing up TSM for shard 7
2025/10/31 15:30:49 INFO: Backing up TSM for shard 8
2025/10/31 15:30:49 INFO: Backing up TSM for shard 9
2025/10/31 15:30:49 INFO: Backing up TSM for shard 10
2025/10/31 15:30:50 INFO: Backing up TSM for shard 11
```

## Restore to the local InfluxDB 

Set the configuration back to local and restore
```
$ influx config set -n bobbins --active
$ influx restore .
2025/10/31 15:54:57 INFO: Restoring bucket "0123456789a" as "bobbins-data"
Error: failed to restore bucket "bobbins-data": 422 Unprocessable Entity: bucket with name bobbins-data already exists
tng@macos prd % influx restore .
2025/10/31 15:55:10 INFO: Restoring bucket "0123456789a" as "bobbins-data"
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 49
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 50
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 51
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 52
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 53
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 54
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 55
2025/10/31 15:55:10 INFO: Restoring TSM snapshot for shard 56
```

## Extract the Line protocol data from the local InfluxDB instance

We can now extract the data from the local bucket. Find the local bucket id as above using influx bucket list.

```
$ influxd inspect export-lp --bucket-id 9a9876543217 --output-path ./bob1-influx2-$(date +%F).lp
{"level":"info","ts":1761926299.37861,"caller":"export_lp/export_lp.go:219","msg":"exporting TSM files","tsm_dir":"/home/tng/.influxdbv2/engine/data/9a9876543217","file_count":8}
{"level":"info","ts":1761926300.2268832,"caller":"export_lp/export_lp.go:315","msg":"exporting WAL files","wal_dir":"/home/tng/.influxdbv2/engine/wal/9a9876543217","file_count":0}
{"level":"info","ts":1761926300.2269042,"caller":"export_lp/export_lp.go:204","msg":"export complete"}
```

## Split the line protocol data into smaller files. 

We can't split based on bytes because the line protocol data needs to not end mid-line and be smaller than 10MB. You may have to experiment with the 80000 value depending on how long the lines are. ```split``` is slow when working with lines.

```
$ split -l80000 bob1-export-lp-2025-10-31.lp
```

## Import the Line Protocol data into InfluxDBv3

Set the API token for the InfluxDBv3 database.

```
export AUTH_TOKEN=apiv3_abcfdfgfgffgfdgfgdgdfgg
```

Create and run a shell script similar to the following (we called it ```import_prd1.sh```): 

```
#!/bin/bash
for file in x??
do
    echo $file
    /usr/local/influxdb3/influxdb3 write -H "https://endpoint.on.aws:8181/api/v3/query_sql" -d bobbins-data --token $AUTH_TOKEN --file $file
sleep 2
done
```


Run the script:

```
$ chmod a+x ./import_prd1.sh
$ ./import_prd1.sh 
xaa
success
xab
success
xac
success
xad
success
xae
success        
```

Check that the data has been correctly imported into the Timestream v3 database.

## Thoughts on InfluxDB v3

- The licencing of Timestream for InfluxDB 3 is distinctly odd. You are paying for a subscription through the marketplace and the infrastructure.
- The influxdb3 binary is really odd. The combined server and client binary goes against 50 years of UNIX design of doing one job and doing it well. I'd love to know why. 
- It feels like influxdata have thrown the baby out with the bathwater when they decided it was necessary to rewrite everything in Rust. 
- Getting rid of Flux. I personally would have preferred it being kept for one major release, it's jarring to have to change languages so often.
- The documentation is nearly adequate, but an unsearchable mess because of the versioning. I think Django makes a much better job of versioning and it would be good for influxdata to have another think about this.
- InfluxDB 3 Core 72 hour retention for "performance reasons", makes no sense. Just admit that it's a bait and switch and be honest with your customers.

