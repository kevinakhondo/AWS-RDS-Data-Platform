resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.az_a
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.az_b
}

resource "aws_subnet" "vpn" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.vpn_subnet_cidr
  availability_zone       = var.az_a
  map_public_ip_on_launch = true
}
