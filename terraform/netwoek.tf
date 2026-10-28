# ---------- VPC ----------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # needed so the RDS endpoint name resolves inside the VPC

  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# ---------- Public subnets: the k3s node ----------

resource "aws_subnet" "public" {
  for_each = local.az_index

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 1) # 10.0.1.0/24, 10.0.2.0/24
  map_public_ip_on_launch = true                                        # the node needs internet during first boot to install k3s

  tags = {
    Name = "${var.project}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ---------- Private subnets: RDS only, no internet ----------

resource "aws_subnet" "private" {
  for_each = local.az_index

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + 11) # 10.0.11.0/24, 10.0.12.0/24

  tags = {
    Name = "${var.project}-private-${each.key}"
    Tier = "private"
  }
}

# Deliberately has no routes except the automatic "local" route inside the VPC
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    Name = "${var.project}-db-subnet-group"
  }
}
