output "private_subnet_ids" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "vpn_subnet_id" {
  value = aws_subnet.vpn.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}
