resource "aws_iam_role" "aws_load_balancer_controller" {

  name = "${local.project_prefix}-aws-load-balancer-controller-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Federated = aws_iam_openid_connect_provider.eks.arn

        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {

          StringEquals = {

            "${replace(
              aws_iam_openid_connect_provider.eks.url,
              "https://",
              ""
            )}:aud" = "sts.amazonaws.com"

            "${replace(
              aws_iam_openid_connect_provider.eks.url,
              "https://",
              ""
            )}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"

          }

        }

      }

    ]

  })

  tags = {

    Name = "${local.project_prefix}-aws-load-balancer-controller-role"

  }

}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {

  role = aws_iam_role.aws_load_balancer_controller.name

  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn

}

resource "aws_iam_policy" "aws_load_balancer_controller" {

  name = "${local.project_prefix}-AWSLoadBalancerControllerIAMPolicy"

  description = "IAM policy for AWS Load Balancer Controller"

  policy = file(
    "${path.module}/policies/aws-load-balancer-controller-policy.json"
  )

  tags = {

    Name = "${local.project_prefix}-aws-load-balancer-controller-policy"

  }

}