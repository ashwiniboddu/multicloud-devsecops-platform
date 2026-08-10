Phase 1 – Provision AWS Infrastructure using Terraform
================================================================================================================================================

Objective:

The objective of this phase is to provision the complete AWS infrastructure required for the Multi-Cloud DevSecOps Platform using Terraform.

This phase creates the networking components, compute resources, storage, container registry, IAM permissions, Kubernetes cluster, and supporting services. All infrastructure is defined as code, making the environment reusable, version-controlled, and easy to recreate.
================================================================================================================================================

Files Used
---------------

provider.tf

Purpose:
Configures the AWS provider and specifies the AWS region where all resources will be created.

Why this file exists:
Terraform needs to know which cloud provider it should communicate with before creating any infrastructure.
================================================================================================================================================
versions.tf

Purpose:
Specifies the required Terraform version and AWS provider version.

Why this file exists:
Keeps Terraform executions consistent across different environments and prevents version compatibility issues.
================================================================================================================================================
variables.tf

Purpose:
Defines all input variables used throughout the Terraform configuration.

Examples include:

AWS Region
Project Name
VPC CIDR
Public Subnet CIDRs
Private Subnet CIDRs
EC2 Instance Type
Cluster Name
Why this file exists

Avoids hardcoding values and makes the infrastructure reusable.
================================================================================================================================================
terraform.tfvars

Purpose:
Stores the actual values for all Terraform variables.

Why this file exists:
Separates configuration values from Terraform code, allowing the same infrastructure to be deployed in multiple environments.
================================================================================================================================================
locals.tf

Purpose:
Defines reusable local values such as naming conventions and common tags.

Why this file exists:
Reduces repetition and keeps naming consistent across all AWS resources.
================================================================================================================================================
vpc.tf

Purpose:
Creates the Virtual Private Cloud (VPC).

Resources Created
VPC

Why this file exists:
The VPC provides an isolated networking environment where all AWS resources are deployed securely.
================================================================================================================================================
subnets.tf

Purpose:
Creates networking subnets.

Resources Created
Public Subnet 1
Public Subnet 2
Private Subnet 1
Private Subnet 2

Why this file exists:
Public subnets host internet-facing resources such as the Application Load Balancer.
Private subnets host Kubernetes worker nodes for improved security.
================================================================================================================================================
internet-gateway.tf

Purpose:
Creates the Internet Gateway.

Resources Created
Internet Gateway

Why this file exists:
Allows resources inside public subnets to communicate with the Internet.
================================================================================================================================================
nat-gateway.tf

Purpose:
Creates the NAT Gateway.

Resources Created
Elastic IP
NAT Gateway

Why this file exists:
Allows private subnet resources to access the Internet for updates without exposing them publicly.
================================================================================================================================================
route-tables.tf

Purpose:
Creates route tables and subnet associations.

Resources Created
Public Route Table
Private Route Table
Route Table Associations

Why this file exists:
Controls network traffic between subnets, Internet Gateway, and NAT Gateway.
================================================================================================================================================
security-groups.tf

Purpose:
Creates security groups for infrastructure components.

Resources Created
Jenkins Security Group
ALB Security Group
EKS Cluster Security Group
Worker Node Security Group

Why this file exists:
Acts as the firewall for AWS resources by controlling inbound and outbound traffic.
================================================================================================================================================
key-pair.tf

Purpose:
Creates the EC2 Key Pair.

Resources Created
AWS Key Pair

Why this file exists:
Allows secure SSH access to the Jenkins EC2 instance.
================================================================================================================================================
iam.tf

Purpose:
Creates IAM Roles and Policies.

Resources Created
Jenkins IAM Role
EC2 Instance Profile
Required IAM Policies

Why this file exists:
Provides AWS permissions required by Jenkins and other infrastructure components.
================================================================================================================================================
launch-template.tf

Purpose:
Creates the EC2 Launch Template.

Resources Created
Launch Template

Why this file exists:
Defines the configuration used to launch Jenkins EC2 instances.
================================================================================================================================================
autoscaling.tf

Purpose:
Creates the Auto Scaling Group.

Resources Created
Auto Scaling Group

Why this file exists:
Ensures Jenkins EC2 instances can be automatically recreated if they fail.
================================================================================================================================================
userdata/jenkins.sh

Purpose:
Bootstrap script executed during Jenkins EC2 creation.

Installs
Java
Maven
Git
Docker
Jenkins
kubectl
Helm
AWS CLI
Trivy

Why this file exists:
Automatically prepares the Jenkins server without requiring manual software installation.
================================================================================================================================================
ecr.tf

Purpose:
Creates the Amazon Elastic Container Registry.

Resources Created
ECR Repository

Why this file exists:
Stores Docker images built by the CI/CD pipeline before deployment to Kubernetes.
================================================================================================================================================
s3.tf

Purpose:
Creates the S3 bucket.

Resources Created
S3 Bucket

Why this file exists:
Used for project storage requirements (for example, Terraform state, backups, or future artifacts as needed).
================================================================================================================================================
eks-cluster.tf

Purpose:
Creates the Amazon EKS control plane.

Resources Created
Amazon EKS Cluster

Why this file exists:
Provides the managed Kubernetes control plane for container orchestration.
================================================================================================================================================
eks-node-group.tf

Purpose:
Creates the managed worker nodes.

Resources Created
Managed Node Group

Why this file exists:
Runs application workloads inside the Kubernetes cluster.
================================================================================================================================================
eks-access.tf

Purpose:
Configures cluster access.

Why this file exists:
Allows the required IAM users and roles to manage the EKS cluster.
================================================================================================================================================
eks-oidc.tf

Purpose:
Creates the OIDC provider.

Resources Created
IAM OIDC Provider

Why this file exists:
Allows Kubernetes Service Accounts to securely assume AWS IAM Roles.
================================================================================================================================================
eks-ebs-csi.tf

Purpose:
Installs the Amazon EBS CSI Driver.

Resources Created
EBS CSI Add-on
IAM Role

Why this file exists:
Allows Kubernetes Persistent Volumes to use Amazon EBS storage.
================================================================================================================================================
alb-controller-iam.tf

Purpose:
Creates IAM resources required by the AWS Load Balancer Controller.

Resources Created
IAM Role
IAM Policy

Why this file exists:
Allows Kubernetes to provision and manage AWS Application Load Balancers.
================================================================================================================================================
alb-controller.tf

Purpose:
Installs the AWS Load Balancer Controller.

Resources Created
Helm Release

Why this file exists:
Automatically provisions ALBs for Kubernetes Ingress resources.
================================================================================================================================================
helm-provider.tf

Purpose:
Configures the Terraform Helm Provider.

Why this file exists:
Allows Terraform to install Helm charts directly into the EKS cluster.
================================================================================================================================================
outputs.tf

Purpose:
Displays important infrastructure outputs after deployment.

Example Outputs
VPC ID
Public Subnet IDs
Private Subnet IDs
EKS Cluster Name
Jenkins Public IP
ECR Repository URL
ALB Information

Why this file exists:
Makes important infrastructure details easily available after terraform apply.

Resources Created
================================================================================================================================================
At the end of this phase, the following AWS resources are provisioned:

VPC
Public Subnets
Private Subnets
Internet Gateway
NAT Gateway
Route Tables
Security Groups
EC2 Key Pair
Jenkins EC2 Instance (via Launch Template and Auto Scaling Group)
Amazon ECR Repository
Amazon S3 Bucket
Amazon EKS Cluster
Managed Node Group
IAM Roles and Policies
OIDC Provider
Amazon EBS CSI Driver
AWS Load Balancer Controller
================================================================================================================================================
Commands Executed:

terraform init

terraform validate

terraform plan

terraform apply

Verification

The infrastructure deployment was verified by checking:

Terraform completed successfully without errors.
VPC, subnets, route tables, and gateways were created in AWS.
Jenkins EC2 instance was launched and accessible.
Amazon EKS cluster became active.
Managed worker nodes joined the cluster successfully.
Amazon ECR repository was created.
S3 bucket was created.
AWS Load Balancer Controller was installed successfully.
EBS CSI Driver was installed successfully.