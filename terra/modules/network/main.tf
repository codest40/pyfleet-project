# =======================================================
# NETWORK MODULE v2 - PYFLEET
# =======================================================
# - VPC
# - 2 Public Subnets for ALB
# - 2 Public Subnets for Bastion
# - Private App Subnets
# - Private DB Subnets
# - Internet Gateway
# - 2 NAT Gateways
# - Route Tables
# =======================================================

# =======================================================
# NETWORK MODULE v2 - PYFLEET
# =======================================================

# -------------------------
# VPC
# -------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, { Name = "pyfleet-vpc" })
}

# -------------------------
# Internet Gateway
# -------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "pyfleet-igw" })
}

# -------------------------
# PUBLIC SUBNETS (ALB & BASTION)
# -------------------------
resource "aws_subnet" "public_alb" {
  for_each = { for az in var.azs : az.name => az }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.public_alb
  availability_zone       = each.value.name
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "public-alb-${each.value.name}" })
}

resource "aws_subnet" "public_bastion" {
  for_each = { for az in var.azs : az.name => az }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.public_bastion
  availability_zone       = each.value.name
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "public-bastion-${each.value.name}" })
}

# -------------------------
# PRIVATE SUBNETS (APP & DB)
# -------------------------
resource "aws_subnet" "private_app" {
  for_each = { for az in var.azs : az.name => az }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.private_app
  availability_zone = each.value.name

  tags = merge(var.tags, { Name = "private-app-${each.value.name}" })
}

resource "aws_subnet" "private_db" {
  for_each = { for az in var.azs : az.name => az }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.private_db
  availability_zone = each.value.name

  tags = merge(var.tags, { Name = "private-db-${each.value.name}" })
}

# -------------------------
# NAT GATEWAYS
# -------------------------
resource "aws_eip" "nat" {
  for_each   = aws_subnet.public_alb
  depends_on = [aws_internet_gateway.igw]

  tags = merge(var.tags, { Name = "nat-eip-${each.key}" })
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.public_alb
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public_alb[each.key].id

  tags = merge(var.tags, { Name = "nat-gateway-${each.key}" })
}

# -------------------------
# ROUTE TABLES
# -------------------------
# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "public-rt" })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate public subnets
resource "aws_route_table_association" "public_alb_assoc" {
  for_each       = aws_subnet.public_alb
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_bastion_assoc" {
  for_each       = aws_subnet.public_bastion
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private route tables (one per AZ to attach NAT)
resource "aws_route_table" "private_app" {
  for_each = aws_subnet.private_app

  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "private-app-rt-${each.key}" })
}

resource "aws_route" "private_app_nat_route" {
  for_each = aws_route_table.private_app

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

resource "aws_route_table_association" "private_app_assoc" {
  for_each       = aws_subnet.private_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app[each.key].id
}

resource "aws_route_table" "private_db" {
  for_each = aws_subnet.private_db

  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "private-db-rt-${each.key}" })
}

resource "aws_route" "private_db_nat_route" {
  for_each = aws_route_table.private_db

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

resource "aws_route_table_association" "private_db_assoc" {
  for_each       = aws_subnet.private_db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_db[each.key].id
}

