# variable "cluster_domain" {
#   type = string
# }

variable "deploy_key" {
  type        = string
  description = "Public key to use for deployment"
}
variable "deploy_private_key" {
  type        = string
  description = "Private key to use for deployment"
  sensitive   = true
}
variable "bitwarden_token" {
  type        = string
  description = "Auth token for Bitwarden secret"
  sensitive   = true
}
variable "step_ca_cert" {
  type        = string
  description = "Step CA Cert bundle"
  sensitive   = true
}