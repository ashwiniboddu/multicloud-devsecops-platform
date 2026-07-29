# ============================================================
# AWS CONFIGURATION
# ============================================================

variable "aws_region" {

  description = "AWS region where resources will be created"

  type = string

}


# ============================================================
# PROJECT CONFIGURATION
# ============================================================

variable "project_name" {

  description = "Project name"

  type = string

}

variable "environment_name" {

  description = "Environment name"

  type = string

}


# ============================================================
# NETWORK CONFIGURATION
# ============================================================

variable "vpc_cidr" {

  description = "CIDR block for the main VPC"

  type = string

}


# ============================================================
# JENKINS CONFIGURATION
# ============================================================

variable "jenkins_ami_id" {

  description = "Ubuntu AMI ID used for Jenkins EC2 instances"

  type = string

}

variable "jenkins_instance_type" {

  description = "EC2 instance type used for Jenkins"

  type = string

  default = "t3.medium"

}

variable "public_key_path" {

  description = "Path to the SSH public key used for EC2 access"

  type = string

}


# ============================================================
# EKS CONFIGURATION
# ============================================================

variable "eks_cluster_version" {

  description = "Kubernetes version for the EKS cluster"

  type = string

  default = "1.33"

}

variable "eks_node_instance_type" {

  description = "EC2 instance type for EKS worker nodes"

  type = string

  default = "t3.medium"

}


variable "eks_node_desired_size" {

  description = "Desired number of EKS worker nodes"

  type = number

  default = 2

}


variable "eks_node_min_size" {

  description = "Minimum number of EKS worker nodes"

  type = number

  default = 2

}


variable "eks_node_max_size" {

  description = "Maximum number of EKS worker nodes"

  type = number

  default = 3

}


variable "eks_node_disk_size" {

  description = "Disk size in GB for EKS worker nodes"

  type = number

  default = 30

}