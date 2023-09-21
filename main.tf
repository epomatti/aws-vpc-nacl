terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  workload = "bookstore"
}

module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
  workload   = local.workload
}

module "rds" {
  source  = "./modules/rds"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.data_subnets
  azs     = module.vpc.azs
}
