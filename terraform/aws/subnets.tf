# ============================================================
# PUBLIC SUBNETS
# ============================================================

resource "aws_subnet" "public" {

  for_each = local.public_subnets

  vpc_id = aws_vpc.main.id

  cidr_block = each.value.cidr

  availability_zone = each.value.az

  map_public_ip_on_launch = true

  tags = {

    Name = "${local.project_prefix}-${each.key}"

    Tier = "Public"

  }

}


# ============================================================
# PRIVATE SUBNETS
# ============================================================

resource "aws_subnet" "private" {

  for_each = local.private_subnets

  vpc_id = aws_vpc.main.id

  cidr_block = each.value.cidr

  availability_zone = each.value.az

  map_public_ip_on_launch = false

  tags = {

    Name = "${local.project_prefix}-${each.key}"

    Tier = "Private"

  }

}