### Route Tables ###

resource "aws_route_table" "data1" {
  vpc_id = var.vpc_id
  tags = {
    Name = "rt-${var.workload}-dat1"
  }
}

resource "aws_route_table" "data2" {
  vpc_id = var.vpc_id
  tags = {
    Name = "rt-${var.workload}-dat2"
  }
}

resource "aws_route_table" "data3" {
  vpc_id = var.vpc_id
  tags = {
    Name = "rt-${var.workload}-dat3"
  }
}

### Subnets ###

resource "aws_subnet" "data1" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.90.0/24"
  availability_zone       = var.az1
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-dat1"
  }
}

resource "aws_subnet" "data2" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.91.0/24"
  availability_zone       = var.az2
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-dat2"
  }
}

resource "aws_subnet" "data3" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.92.0/24"
  availability_zone       = var.az3
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-dat3"
  }
}

### Routes ###

resource "aws_route_table_association" "data1" {
  subnet_id      = aws_subnet.data1.id
  route_table_id = aws_route_table.data1.id
}

resource "aws_route_table_association" "data2" {
  subnet_id      = aws_subnet.data2.id
  route_table_id = aws_route_table.data2.id
}

resource "aws_route_table_association" "data3" {
  subnet_id      = aws_subnet.data3.id
  route_table_id = aws_route_table.data3.id
}

### NACLs ###

# https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-groups.html#elb-vpc-nacl
# https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html#nacl-other-services

data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  vpc_cidr_block = data.aws_vpc.selected.cidr_block
}

resource "aws_network_acl" "main" {
  vpc_id = var.vpc_id

  # Allows inbound HTTP traffic from any IPv4 address.
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = local.vpc_cidr_block
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = local.vpc_cidr_block
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "nacl-${var.workload}-aurora"
  }
}

resource "aws_network_acl_association" "subnet_data1" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.data1.id
}

resource "aws_network_acl_association" "subnet_data2" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.data2.id
}

resource "aws_network_acl_association" "subnet_data3" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.data3.id
}
