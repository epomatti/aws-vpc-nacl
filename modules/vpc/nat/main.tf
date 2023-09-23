resource "aws_eip" "nat1" {
  domain = "vpc"
}

resource "aws_eip" "nat2" {
  domain = "vpc"
}

resource "aws_eip" "nat3" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = var.subnets[0]

  tags = {
    Name = "nat-${var.workload}-001"
  }
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = var.subnets[1]

  tags = {
    Name = "nat-${var.workload}-002"
  }
}

resource "aws_nat_gateway" "nat3" {
  allocation_id = aws_eip.nat3.id
  subnet_id     = var.subnets[2]

  tags = {
    Name = "nat-${var.workload}-003"
  }
}
