
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

resource "aws_vpc" "eb_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "eb_vpc"
  }
}

resource "aws_internet_gateway" "eb_vpc_gateway" {
  vpc_id = aws_vpc.eb_vpc.id
}

resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id            = aws_vpc.eb_vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = "${each.key}-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eb_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eb_vpc_gateway.id
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each       = local.public_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  for_each = local.public_subnets
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each      = local.public_subnets
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value
}

resource "aws_route_table" "private_rt" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.eb_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[local.private_to_public[each.key]].id
  }
}

resource "aws_route_table_association" "private_rt_assoc" {
  for_each       = local.private_subnets
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private_rt[each.key].id
}