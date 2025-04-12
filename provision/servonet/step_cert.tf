data "tls_certificate" "step" {
  url = "https://ca.lan/roots.pem"
}