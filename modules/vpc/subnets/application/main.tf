### Routes ###
resource "aws_route_table" "app1" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_ids[0]
  }

  tags = {
    Name = "rt-${var.workload}-app1"
  }
}

resource "aws_route_table" "app2" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_ids[1]
  }

  tags = {
    Name = "rt-${var.workload}-app2"
  }
}

resource "aws_route_table" "app3" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_ids[2]
  }

  tags = {
    Name = "rt-${var.workload}-app3"
  }
}

### Subnets ###

resource "aws_subnet" "app1" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.20.0/24"
  availability_zone = var.az1

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-app1"
  }
}

resource "aws_subnet" "app2" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.21.0/24"
  availability_zone = var.az2

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-app2"
  }
}

resource "aws_subnet" "app3" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.22.0/24"
  availability_zone = var.az3

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-app3"
  }
}

### Routes ###

resource "aws_route_table_association" "app1" {
  subnet_id      = aws_subnet.app1.id
  route_table_id = aws_route_table.app1.id
}

resource "aws_route_table_association" "app2" {
  subnet_id      = aws_subnet.app2.id
  route_table_id = aws_route_table.app2.id
}

resource "aws_route_table_association" "app3" {
  subnet_id      = aws_subnet.app3.id
  route_table_id = aws_route_table.app3.id
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

  ### Ingress ###

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
    rule_no    = 105
    action     = "allow"
    cidr_block = local.vpc_cidr_block # Source
    from_port  = 443
    to_port    = 443
  }

  # Allows inbound return IPv4 traffic from the internet (that is, for requests that originate in the subnet).
  # https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_PortMapping.html
  #
  # Usinhg the VPC CIDR will not work. It has to be 0.0.0.0/0.

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0" # Source
    from_port  = 1024
    to_port    = 65535
  }


  ### Egress ###

  egress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0" # Target
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0" # Target
    from_port  = 443
    to_port    = 443
  }

  # Inclues RDS MySQL 3306
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = local.vpc_cidr_block # Target
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "nacl-${var.workload}-application"
  }
}

resource "aws_network_acl_association" "subnet_app1" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.app1.id
}

resource "aws_network_acl_association" "subnet_app2" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.app2.id
}

resource "aws_network_acl_association" "subnet_app3" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.app3.id
}
