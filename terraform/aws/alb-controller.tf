resource "helm_release" "aws_load_balancer_controller" {

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"

  chart = "aws-load-balancer-controller"

  namespace = "kube-system"

  create_namespace = false

  version = "1.13.0"

  set = [

    {
      name  = "clusterName"
      value = aws_eks_cluster.main.name
    },

    {
      name  = "region"
      value = var.aws_region
    },

    {
      name  = "vpcId"
      value = aws_vpc.main.id
    },

    {
      name  = "serviceAccount.create"
      value = "true"
    },

    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },

    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.aws_load_balancer_controller.arn
    }

  ]

  depends_on = [

    aws_eks_cluster.main,

    aws_iam_role_policy_attachment.aws_load_balancer_controller

  ]

}