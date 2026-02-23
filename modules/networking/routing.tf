resource "aws_route_table" "vpn" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "vpn" {
  subnet_id      = aws_subnet.vpn.id
  route_table_id = aws_route_table.vpn.id
}
