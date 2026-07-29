resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {

    Name = "${local.project_prefix}-nat-eip"

  }

}

resource "aws_nat_gateway" "main" {

  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public["public_a"].id

  tags = {

    Name = "${local.project_prefix}-nat-gateway"

  }

  depends_on = [

    aws_internet_gateway.main

  ]

}