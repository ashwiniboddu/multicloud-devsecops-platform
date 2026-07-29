# ============================================================
# VPC OUTPUTS
# ============================================================

output "vpc_id" {

  description = "ID of the main VPC"

  value = aws_vpc.main.id

}

output "vpc_cidr" {

  description = "CIDR block of the main VPC"

  value = aws_vpc.main.cidr_block

}


# ============================================================
# SUBNET OUTPUTS
# ============================================================

output "public_subnet_ids" {

  description = "IDs of all public subnets"

  value = {
    for key, subnet in aws_subnet.public :
    key => subnet.id
  }

}

output "private_subnet_ids" {

  description = "IDs of all private subnets"

  value = {
    for key, subnet in aws_subnet.private :
    key => subnet.id
  }

}


# ============================================================
# NETWORKING OUTPUTS
# ============================================================

output "internet_gateway_id" {

  description = "ID of the Internet Gateway"

  value = aws_internet_gateway.main.id

}

output "nat_gateway_id" {

  description = "ID of the NAT Gateway"

  value = aws_nat_gateway.main.id

}

output "public_route_table_id" {

  description = "ID of the public route table"

  value = aws_route_table.public.id

}

output "private_route_table_id" {

  description = "ID of the private route table"

  value = aws_route_table.private.id

}


# ============================================================
# SECURITY GROUP OUTPUTS
# ============================================================

output "alb_security_group_id" {

  description = "Security Group ID for the Application Load Balancer"

  value = aws_security_group.alb_sg.id

}

output "jenkins_security_group_id" {

  description = "Security Group ID for Jenkins"

  value = aws_security_group.jenkins_sg.id

}

output "eks_security_group_id" {

  description = "Security Group ID for EKS"

  value = aws_security_group.eks_sg.id

}


# ============================================================
# STORAGE OUTPUTS
# ============================================================

output "artifacts_bucket_name" {

  description = "Name of the S3 bucket used for application artifacts"

  value = aws_s3_bucket.project_bucket.bucket

}

output "artifacts_bucket_arn" {

  description = "ARN of the S3 application artifacts bucket"

  value = aws_s3_bucket.project_bucket.arn

}


# ============================================================
# ECR OUTPUTS
# ============================================================

output "ecr_repository_name" {

  description = "Name of the ECR repository"

  value = aws_ecr_repository.app.name

}

output "ecr_repository_url" {

  description = "URL of the ECR repository"

  value = aws_ecr_repository.app.repository_url

}

output "ecr_repository_arn" {

  description = "ARN of the ECR repository"

  value = aws_ecr_repository.app.arn

}

# ============================================================
# IAM OUTPUTS
# ============================================================

output "jenkins_iam_role_name" {

  description = "IAM role name attached to Jenkins EC2"

  value = aws_iam_role.jenkins_role.name

}

output "jenkins_instance_profile_name" {

  description = "Instance profile attached to Jenkins EC2"

  value = aws_iam_instance_profile.jenkins_profile.name

}

output "eks_cluster_role_name" {

  description = "IAM role used by the EKS control plane"

  value = aws_iam_role.eks_cluster_role.name

}

output "eks_node_role_name" {

  description = "IAM role used by EKS worker nodes"

  value = aws_iam_role.eks_node_role.name

}

output "eks_oidc_issuer_url" {

  description = "EKS OIDC issuer URL"

  value = aws_eks_cluster.main.identity[0].oidc[0].issuer

}

output "eks_oidc_provider_arn" {

  description = "EKS OIDC provider ARN"

  value = aws_iam_openid_connect_provider.eks.arn

}

output "aws_load_balancer_controller_role_arn" {

  description = "IAM role ARN for AWS Load Balancer Controller"

  value = aws_iam_role.aws_load_balancer_controller.arn

}

# ============================================================
# LOAD BALANCER OUTPUTS
# ============================================================

output "alb_dns_name" {

  description = "DNS name of the Application Load Balancer"

  value = aws_lb.main.dns_name

}

output "alb_arn" {

  description = "ARN of the Application Load Balancer"

  value = aws_lb.main.arn

}

output "jenkins_target_group_arn" {

  description = "ARN of the Jenkins target group"

  value = aws_lb_target_group.jenkins.arn

}


# ============================================================
# COMPUTE OUTPUTS
# ============================================================

output "jenkins_launch_template_id" {

  description = "ID of the Jenkins Launch Template"

  value = aws_launch_template.jenkins.id

}

output "jenkins_autoscaling_group_name" {

  description = "Name of the Jenkins Auto Scaling Group"

  value = aws_autoscaling_group.jenkins.name

}

# ============================================================
# EKS OUTPUTS
# ============================================================

output "eks_cluster_name" {

  description = "Name of the EKS cluster"

  value = aws_eks_cluster.main.name

}

output "eks_cluster_endpoint" {

  description = "Endpoint of the EKS Kubernetes API server"

  value = aws_eks_cluster.main.endpoint

}

output "eks_cluster_arn" {

  description = "ARN of the EKS cluster"

  value = aws_eks_cluster.main.arn

}

output "eks_node_group_name" {

  description = "Name of the EKS managed node group"

  value = aws_eks_node_group.main.node_group_name

}