### Routes ###
resource "aws_route_table" "elb1" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.interget_gateway_id
  }

  tags = {
    Name = "rt-${var.workload}-elb1"
  }
}

resource "aws_route_table" "elb2" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.interget_gateway_id
  }

  tags = {
    Name = "rt-${var.workload}-elb2"
  }
}

resource "aws_route_table" "elb3" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.interget_gateway_id
  }

  tags = {
    Name = "rt-${var.workload}-elb3"
  }
}

### Subnets ###

resource "aws_subnet" "elb1" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.10.0/24"
  availability_zone = var.az1

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-elb1"
  }
}

resource "aws_subnet" "elb2" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.11.0/24"
  availability_zone = var.az2

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-elb2"
  }
}

resource "aws_subnet" "elb3" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.12.0/24"
  availability_zone = var.az3

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-elb3"
  }
}

### Routes ###

resource "aws_route_table_association" "elb1" {
  subnet_id      = aws_subnet.elb1.id
  route_table_id = aws_route_table.elb1.id
}

resource "aws_route_table_association" "elb2" {
  subnet_id      = aws_subnet.elb2.id
  route_table_id = aws_route_table.elb2.id
}

resource "aws_route_table_association" "elb3" {
  subnet_id      = aws_subnet.elb3.id
  route_table_id = aws_route_table.elb3.id
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
    cidr_block = "0.0.0.0/0" # Source
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = local.vpc_cidr_block # Target
    from_port  = 80
    to_port    = 80
  }

  # Allows inbound return IPv4 traffic from the internet (that is, for requests that originate in the subnet).
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = local.vpc_cidr_block
    from_port  = 1024 # 32768
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0" # Target
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "nacl-${var.workload}-elb"
  }
}

resource "aws_network_acl_association" "subnet_elb1" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.elb1.id
}

resource "aws_network_acl_association" "subnet_elb2" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.elb2.id
}

resource "aws_network_acl_association" "subnet_elb3" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.elb3.id
}
