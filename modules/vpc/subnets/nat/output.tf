output "subnets" {
  value = [aws_subnet.nat1.id, aws_subnet.nat2.id, aws_subnet.nat3.id]
}
