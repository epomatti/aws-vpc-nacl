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

module "elb" {
  source   = "./modules/elb"
  workload = local.workload
  subnets  = module.vpc.elb_subnets
  vpc_id   = module.vpc.vpc_id
}

module "iam" {
  source   = "./modules/iam"
  workload = local.workload
}

module "ecr" {
  source   = "./modules/ecr"
  workload = local.workload
}

module "ecs" {
  source                      = "./modules/ecs"
  workload                    = local.workload
  subnets                     = module.vpc.application_subnets
  vpc_id                      = module.vpc.vpc_id
  aws_region                  = var.aws_region
  ecr_repository_url          = module.ecr.repository_url
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn
  target_group_arn            = module.elb.target_group_arn
  task_cpu                    = var.ecs_task_cpu
  task_memory                 = var.ecs_task_memory
}

module "ssm" {
  source          = "./modules/ssm"
  workload        = local.workload
  aurora_username = module.rds.master_username
  aurora_password = module.rds.master_password
  aurora_endpoint = module.rds.endpoint
}
