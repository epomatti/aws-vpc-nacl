locals {
  master_username = "aurora"
  master_password = "p4ssw0rd"
}

resource "aws_rds_cluster" "default" {
  cluster_identifier     = "aurora-cluster-1"
  engine                 = "aurora-mysql"
  engine_version         = "8.0.mysql_aurora.3.04.0"
  availability_zones     = var.azs
  database_name          = "database1"
  master_username        = local.master_username
  master_password        = local.master_password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.allow_postgresql.id]

  lifecycle {
    ignore_changes = [availability_zones]
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier          = "aurora-instance-1"
  publicly_accessible = false
  cluster_identifier  = aws_rds_cluster.default.id
  instance_class      = "db.t4g.medium"
  engine              = aws_rds_cluster.default.engine
  engine_version      = aws_rds_cluster.default.engine_version
}

resource "aws_db_subnet_group" "default" {
  name       = "aurora-1"
  subnet_ids = var.subnets
}

resource "aws_security_group" "allow_postgresql" {
  name        = "rds-aurora"
  description = "Allow TLS inbound traffic to RDS Postgres"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-rds-aurora"
  }
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_postgresql.id
}
