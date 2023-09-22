output "elb_dns_name" {
  value = module.elb.dns_name
}

output "aurora_endpoint" {
  value = module.rds.endpoint
}
