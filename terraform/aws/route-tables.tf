resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.main.id

  }

  tags = {

    Name = "${local.project_prefix}-public-rt"

    Tier = "Public"

  }

}

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.main.id

  }

  tags = {

    Name = "${local.project_prefix}-private-rt"

    Tier = "Private"

  }

}

resource "aws_route_table_association" "public" {

  for_each = local.public_subnets

  subnet_id = aws_subnet.public[each.key].id

  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "private" {

  for_each = local.private_subnets

  subnet_id = aws_subnet.private[each.key].id

  route_table_id = aws_route_table.private.id

}