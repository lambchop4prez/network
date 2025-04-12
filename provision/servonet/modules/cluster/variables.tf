variable "cluster_name" {
  type = string
}
variable "talos_version" {
  type = string
}
variable "kubernetes_version" {
  type = string
}
variable "controlplane_ips" {
  type = list(string)
}
variable "virtual_ip_address" {
  type = string
}
variable "schematic" {
  type = string
}
variable "step_ca_cert" {
  type      = string
  sensitive = true
}