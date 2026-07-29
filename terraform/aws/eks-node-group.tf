resource "aws_eks_node_group" "main" {

  cluster_name = aws_eks_cluster.main.name

  node_group_name = "${local.project_prefix}-node-group"

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = [

    aws_subnet.private["private_a"].id,
    aws_subnet.private["private_b"].id

  ]

  instance_types = [

    var.eks_node_instance_type

  ]

  capacity_type = "ON_DEMAND"

  scaling_config {

    desired_size = var.eks_node_desired_size

    min_size = var.eks_node_min_size

    max_size = var.eks_node_max_size

  }

  disk_size = var.eks_node_disk_size

  update_config {

    max_unavailable = 1

  }

  tags = {

    Name = "${local.project_prefix}-eks-node"

    Role = "EKS-Worker"

  }

  depends_on = [

    aws_iam_role_policy_attachment.eks_worker_node_policy,

    aws_iam_role_policy_attachment.eks_cni_policy,

    aws_iam_role_policy_attachment.eks_ecr_readonly

  ]

}