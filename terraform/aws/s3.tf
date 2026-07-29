resource "aws_s3_bucket" "project_bucket" {

  bucket = "${local.project_prefix}-artifacts"

  tags = {

    Name = "${local.project_prefix}-artifacts"

    Purpose = "Application artifacts"

  }

}

resource "aws_s3_bucket_versioning" "project_bucket" {

  bucket = aws_s3_bucket.project_bucket.id

  versioning_configuration {

    status = "Enabled"

  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "project_bucket" {

  bucket = aws_s3_bucket.project_bucket.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "AES256"

    }

  }

}

resource "aws_s3_bucket_public_access_block" "project_bucket" {

  bucket = aws_s3_bucket.project_bucket.id

  block_public_acls = true

  block_public_policy = true

  ignore_public_acls = true

  restrict_public_buckets = true

}

resource "aws_s3_bucket_lifecycle_configuration" "project_bucket" {

  bucket = aws_s3_bucket.project_bucket.id

  rule {

    id = "artifact-lifecycle"

    status = "Enabled"

    filter {}

    transition {

      days = 30

      storage_class = "STANDARD_IA"

    }

    expiration {

      days = 365

    }

  }

}