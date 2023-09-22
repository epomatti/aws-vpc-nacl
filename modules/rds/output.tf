output "endpoint" {
  value = aws_rds_cluster.default.endpoint
}

output "master_username" {
  value = local.master_username
}

output "master_password" {
  value = local.master_password
}
