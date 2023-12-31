locals {
  name = "jb-${var.workload}"
}

data "aws_subnet" "selected" {
  id = var.subnet
}

resource "aws_iam_instance_profile" "jumpserver" {
  name = local.name
  role = aws_iam_role.jumpserver.id
}

resource "aws_instance" "jumpserver" {
  ami           = "ami-08fdd91d87f63bb09"
  instance_type = "t4g.nano"

  associate_public_ip_address = false
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [aws_security_group.jumpserver.id]

  availability_zone    = data.aws_subnet.selected.availability_zone
  iam_instance_profile = aws_iam_instance_profile.jumpserver.id
  user_data            = file("${path.module}/userdata.sh")

  # Enables metadata V2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  #checkov:skip=CKV_AWS_126:Bastion host
  monitoring = false

  #checkov:skip=CKV_AWS_135:Bastion host
  ebs_optimized = false

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = local.name
  }
}

### IAM Role ###

resource "aws_iam_role" "jumpserver" {
  name = local.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm-managed-instance-core" {
  role       = aws_iam_role.jumpserver.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "jumpserver" {
  name        = "ec2-ssm-${local.name}"
  description = "Controls access for EC2 via Session Manager"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-ec2-ssm-${local.name}"
  }
}

resource "aws_security_group_rule" "egress_internet_http" {
  description       = "Allow connection to get packages, as well as to connect to the private subnet"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jumpserver.id
}

resource "aws_security_group_rule" "egress_internet_https" {
  description       = "Allow connection to get packages, as well as to connect to the private subnet"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jumpserver.id
}
