resource "aws_key_pair" "main" {

  key_name = "${local.project_prefix}-key"

  public_key = file(var.public_key_path)

  tags = {

    Name = "${local.project_prefix}-key"

  }

}