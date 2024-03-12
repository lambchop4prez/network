resource "random_id" "controlplane_node_id" {
  byte_length = 2
  count       = var.controlplane_count
}
