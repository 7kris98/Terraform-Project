output "prod_private_subnet_ids" {
  value = aws_subnet.prod_private_subnet[*].id
}
output "vpc_id" {
  value = aws_vpc.prod.id
}
