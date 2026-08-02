resource "aws_eks_cluster" "main" {

  name = "${local.project_prefix}-eks"

  role_arn = aws_iam_role.eks_cluster_role.arn

  version = var.eks_cluster_version

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {

    subnet_ids = [
      aws_subnet.private["private_a"].id,
      aws_subnet.private["private_b"].id
    ]

    security_group_ids = [
      aws_security_group.eks_sg.id
    ]

    endpoint_private_access = true

    endpoint_public_access = true

    public_access_cidrs = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${local.project_prefix}-eks"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}