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
