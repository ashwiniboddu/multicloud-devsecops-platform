# ============================================================
# EBS CSI DRIVER - IAM TRUST POLICY
# ============================================================

data "aws_iam_policy_document" "ebs_csi_assume_role" {

  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {

      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]

    }

    condition {

      test = "StringEquals"

      variable = "${replace(
        aws_iam_openid_connect_provider.eks.url,
        "https://",
        ""
      )}:aud"

      values = [
        "sts.amazonaws.com"
      ]

    }

    condition {

      test = "StringEquals"

      variable = "${replace(
        aws_iam_openid_connect_provider.eks.url,
        "https://",
        ""
      )}:sub"

      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      ]

    }

  }

}


# ============================================================
# EBS CSI DRIVER - IAM ROLE
# ============================================================

resource "aws_iam_role" "ebs_csi_driver" {

  name = "${local.project_prefix}-ebs-csi-driver-role"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = local.common_tags

}


# ============================================================
# EBS CSI DRIVER - IAM POLICY ATTACHMENT
# ============================================================

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {

  role = aws_iam_role.ebs_csi_driver.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"

}


# ============================================================
# EBS CSI DRIVER - EKS ADD-ON
# ============================================================

resource "aws_eks_addon" "ebs_csi_driver" {

  cluster_name = aws_eks_cluster.main.name

  addon_name = "aws-ebs-csi-driver"

  addon_version = "v1.51.0-eksbuild.1"

  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "PRESERVE"

  tags = local.common_tags

  depends_on = [

    aws_iam_role_policy_attachment.ebs_csi_driver,

    aws_eks_node_group.main

  ]

}


# ============================================================
# EBS GP3 STORAGE CLASS
# ============================================================

resource "kubernetes_storage_class_v1" "ebs_gp3" {

  metadata {

    name = "ebs-gp3"

    annotations = {

      "storageclass.kubernetes.io/is-default-class" = "true"

    }

  }

  storage_provisioner = "ebs.csi.aws.com"

  reclaim_policy = "Delete"

  volume_binding_mode = "WaitForFirstConsumer"

  allow_volume_expansion = true

  parameters = {

    type = "gp3"

    fsType = "ext4"

    encrypted = "true"

  }

  depends_on = [

    aws_eks_addon.ebs_csi_driver

  ]

}