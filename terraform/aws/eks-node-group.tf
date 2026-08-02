resource "aws_eks_node_group" "main" {

  cluster_name = aws_eks_cluster.main.name

  node_group_name = "${local.project_prefix}-node-group"

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    aws_subnet.private["private_a"].id,
    aws_subnet.private["private_b"].id
  ]

  ami_type = "AL2023_x86_64_STANDARD"

  instance_types = [
    "t3.medium"
  ]

  disk_size = 30

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_eks_cluster.main,

    aws_iam_role_policy_attachment.eks_worker_node_policy,

    aws_iam_role_policy_attachment.eks_cni_policy,

    aws_iam_role_policy_attachment.eks_container_registry_read_only
  ]
}