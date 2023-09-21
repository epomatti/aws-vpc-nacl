output "vpc_id" {
  value = aws_vpc.main.id
}

output "azs" {
  value = local.azs
}

output "data_subnets" {
  value = module.data_subnets.subnets
}
