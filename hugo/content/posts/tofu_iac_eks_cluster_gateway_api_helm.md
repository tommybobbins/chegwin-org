---
title: "EKS Cluster + Gateway API using Tofu/Terraform"
date: 2024-09-15T08:40:03Z
type: "page"
showTableOfContents: true
---
# Streamlining EKS Cluster + Ingress Setup with Tofu/Terraform and GitHub Actions

As Kubernetes continues to gain popularity as the de facto standard for container orchestration, managing and deploying clusters in a consistent and repeatable manner becomes increasingly important. In this blog post, we'll explore a minimal and streamlined approach to creating and managing an Amazon Elastic Kubernetes Service (EKS) cluster on AWS using Infrastructure as Code (IaC) principles, leveraging Terraform configurations and GitHub Actions workflows. Additionally, the repository provides a setup for deploying a Gateway API ingress using Kong or NGINX Fabric Gateway.

## The Repository: EKS_Cluster_Minimal_Setup

The [EKS_Cluster_Minimal_Setup](https://github.com/tommybobbins/EKS_Cluster_Minimal_Setup) repository on GitHub provides a comprehensive solution for automating the creation and management of an EKS cluster, as well as deploying a Gateway API ingress using Kong or NGINX Fabric Gateway. Let's dive into the key components and features of this repository.

### Terraform Configurations

At the heart of the repository are the Terraform configurations (`main.tf` and `variables.tf`) that define the necessary resources for setting up an EKS cluster. These resources include:

- Virtual Private Cloud (VPC)
- Security groups
- EKS Cluster
- Worker nodes (EC2 instances)
- IAM roles
- Network Load Balancer provisioned within Kubernetes

By leveraging Terraform's declarative approach, these configurations ensure consistent and reproducible infrastructure deployments, enabling version control and collaboration among team members.

### GitHub Actions Workflows

To further streamline the deployment process, the repository includes two GitHub Actions workflows:

1. **eks-deployment**: This workflow is triggered when changes are pushed to the `main` branch or when a manual trigger is run. It automates the process of creating the EKS cluster by executing the necessary Terraform commands.
2. **k8s-deployment**: This workflow is triggered when changes are pushed to the `main` branch or when a manual trigger is run. It automates the process of creating the load balancer/Gateway-API via the necessary Terraform commands.
3. **eks-teardown**: It automates the process of destroying the EKS cluster by executing the appropriate `tofu destroy` command.
3. **k8s-teardown**: Automates the process of destroying the kubernetes resources by executing the appropriate `tofu destroy` command.

By integrating with GitHub Actions, the repository leverages the power of Continuous Integration/Continuous Deployment (CI/CD) principles, ensuring that the EKS cluster can be created or destroyed with minimal manual intervention.

### Gateway API Ingress with Kong or NGINX Fabric Gateway

One of the notable features of this repository is the inclusion of a `k8s/gateway.tf` file, which provisions a Network Load Balancer for the EKS cluster. This load balancer enables the deployment of a Gateway API ingress using Kong or NGINX Fabric Gateway, allowing you to expose your applications to the internet or internal networks seamlessly.

## Getting Started

To get started with the "EKS_Cluster_Minimal_Setup" repository, follow these steps:

1. Clone the repository: `git clone https://github.com/tommybobbins/EKS_Cluster_Minimal_Setup.git`
2. Navigate to the repository directory: `cd EKS_Cluster_Minimal_Setup`
3. Configure the required AWS credentials and variables in the `terraform.tfvars` file or configuring the environments and secrets in Github.
4. Create the EKS cluster by triggering the workflow or running the tofu commands..
5. After the cluster is created, you can interact with it using the `kubectl` command-line tool.
6. To deploy the Gateway API ingress using Kong or NGINX Fabric Gateway, follow the instructions in the repository's documentation.
7. To destroy the EKS cluster, run the manual trigger for the k8s-teardown, then the eks-teardown.
8. I'd recommend using bigger instances than the t3.small by editing the `var.instance_types` in `eks/variables.tf`.

## Conclusion

The "EKS_Cluster_Minimal_Setup" repository provides a streamlined and approach to creating and managing EKS clusters on AWS, and deploying a Gateway API ingress using Kong or NGINX Fabric Gateway. By leveraging Terraform configurations and GitHub Actions workflows, it embraces the principles of Infrastructure as Code (IaC) and Continuous Integration/Continuous Deployment (CI/CD). This approach ensures consistent and reproducible infrastructure deployments, enabling version control, collaboration, and easier management of the EKS cluster infrastructure.

