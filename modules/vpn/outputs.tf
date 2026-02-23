output "client_certificate" {
  value = tls_locally_signed_cert.client.cert_pem
}

output "client_private_key" {
  value     = tls_private_key.client.private_key_pem
  sensitive = true
}

output "ca_certificate" {
  value = tls_self_signed_cert.ca.cert_pem
}
