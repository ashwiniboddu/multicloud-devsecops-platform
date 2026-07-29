resource "aws_ecr_repository" "app" {

  name = "${local.project_prefix}-app"

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {

    scan_on_push = true

  }

  encryption_configuration {

    encryption_type = "AES256"

  }

  tags = {

    Name = "${local.project_prefix}-ecr"

    Purpose = "Application container images"

  }

}

resource "aws_ecr_lifecycle_policy" "app" {

  repository = aws_ecr_repository.app.name

  policy = jsonencode({

    rules = [

      {

        rulePriority = 1

        description = "Keep only the latest 20 images"

        selection = {

          tagStatus = "any"

          countType = "imageCountMoreThan"

          countNumber = 20

        }

        action = {

          type = "expire"

        }

      }

    ]

  })

}