output "nat_gateway_ids" {
  value = [aws_nat_gateway.nat1.id, aws_nat_gateway.nat2.id, aws_nat_gateway.nat3.id]
}
