resource "aws_security_group" "alb_sg" {

  name = "${local.project_prefix}-alb-sg"

  description = "Security group for Application Load Balancer"

  vpc_id = aws_vpc.main.id

  ingress {

    description = "Allow HTTP traffic"

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  ingress {

    description = "Allow HTTPS traffic"

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  egress {

    description = "Allow all outbound traffic"

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  tags = {

    Name = "${local.project_prefix}-alb-sg"

    Tier = "Public"

  }

}

resource "aws_security_group" "jenkins_sg" {

  name        = "${local.project_prefix}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow Jenkins traffic from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${local.project_prefix}-jenkins-sg"
    Tier = "Private"
  }
}

resource "aws_security_group" "eks_sg" {

  name = "${local.project_prefix}-eks-sg"

  description = "Security group for EKS cluster"

  vpc_id = aws_vpc.main.id

  ingress {

    description = "Allow HTTPS API access"

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  egress {

    description = "Allow all outbound traffic"

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  tags = {

    Name = "${local.project_prefix}-eks-sg"

    Tier = "Private"

  }

}