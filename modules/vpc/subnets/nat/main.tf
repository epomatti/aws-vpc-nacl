### Routes ###
resource "aws_route_table" "nat1" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.interget_gateway_id
  }

  tags = {
    Name = "rt-${var.workload}-nat1"
  }
}

resource "aws_route_table" "nat2" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.interget_gateway_id
  }

  tags = {
    Name = "rt-${var.workload}-nat2"
  }
}

resource "aws_route_table" "nat3" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.interget_gateway_id
  }

  tags = {
    Name = "rt-${var.workload}-nat3"
  }
}

### Subnets ###

resource "aws_subnet" "nat1" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.100.0/24"
  availability_zone = var.az1

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-nat1"
  }
}

resource "aws_subnet" "nat2" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.101.0/24"
  availability_zone = var.az2

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-nat2"
  }
}

resource "aws_subnet" "nat3" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.102.0/24"
  availability_zone = var.az3

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-nat3"
  }
}

### Routes ###

resource "aws_route_table_association" "nat1" {
  subnet_id      = aws_subnet.nat1.id
  route_table_id = aws_route_table.nat1.id
}

resource "aws_route_table_association" "nat2" {
  subnet_id      = aws_subnet.nat2.id
  route_table_id = aws_route_table.nat2.id
}

resource "aws_route_table_association" "nat3" {
  subnet_id      = aws_subnet.nat3.id
  route_table_id = aws_route_table.nat3.id
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
    cidr_block = local.vpc_cidr_block # Source
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = local.vpc_cidr_block # Source
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allows inbound return IPv4 traffic from the internet (that is, for requests that originate in the subnet).
  # https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_PortMapping.html
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0" # Source
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = local.vpc_cidr_block # Target
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "nacl-${var.workload}-nat"
  }
}

resource "aws_network_acl_association" "subnet_nat1" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.nat1.id
}

resource "aws_network_acl_association" "subnet_nat2" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.nat2.id
}

resource "aws_network_acl_association" "subnet_nat3" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.nat3.id
}
