
output "client_certificate" {
  value = module.vpn.client_certificate
}

output "client_private_key" {
  value     = module.vpn.client_private_key
  sensitive = true
}

output "ca_certificate" {
  value = module.vpn.ca_certificate
}
