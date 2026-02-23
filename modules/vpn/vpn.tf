resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "${var.project_name}-vpn"
  client_cidr_block      = "172.16.0.0/22"
  server_certificate_arn = aws_acm_certificate.vpn.arn
  split_tunnel           = true

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn.arn
  }

  connection_log_options {
    enabled = false
  }

  tags = {
    Name        = "${var.project_name}-dev-client-vpn"
    Environment = "dev"
  }
}

resource "aws_ec2_client_vpn_network_association" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = var.vpn_subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
}

