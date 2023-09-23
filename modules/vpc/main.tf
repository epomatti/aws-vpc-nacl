locals {
  az1 = "${var.aws_region}a"
  az2 = "${var.aws_region}b"
  az3 = "${var.aws_region}c"

  azs = [local.az1, local.az2, local.az3]
}

### VPC ###

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  # Enable DNS hostnames 
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.workload}"
  }
}

### Internet Gateway ###

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig-${var.workload}"
  }
}

### Subnets ###

module "data_subnets" {
  source   = "./subnets/data"
  vpc_id   = aws_vpc.main.id
  workload = var.workload

  az1 = local.az1
  az2 = local.az2
  az3 = local.az3
}

module "nat_subnets" {
  source              = "./subnets/nat"
  vpc_id              = aws_vpc.main.id
  interget_gateway_id = aws_internet_gateway.main.id
  workload            = var.workload

  az1 = local.az1
  az2 = local.az2
  az3 = local.az3
}

module "nat_gateways" {
  source   = "./nat"
  workload = var.workload
  subnets  = module.nat_subnets.subnets
}

module "application_subnets" {
  source          = "./subnets/application"
  vpc_id          = aws_vpc.main.id
  workload        = var.workload
  nat_gateway_ids = module.nat_gateways.nat_gateway_ids

  az1 = local.az1
  az2 = local.az2
  az3 = local.az3
}

module "balancer_subnets" {
  source              = "./subnets/balancer"
  vpc_id              = aws_vpc.main.id
  interget_gateway_id = aws_internet_gateway.main.id
  workload            = var.workload

  az1 = local.az1
  az2 = local.az2
  az3 = local.az3
}

module "jumpserver" {
  source   = "./jumpserver"
  workload = var.workload
  subnet   = module.application_subnets.subnets[0]
  vpc_id   = aws_vpc.main.id
}

# Clear all default entries (CKV2_AWS_12)
resource "aws_default_route_table" "internet" {
  default_route_table_id = aws_vpc.main.default_route_table_id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id
}
