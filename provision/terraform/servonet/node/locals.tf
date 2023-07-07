locals {
  hostname = "tom-${random_id.node_id.id}"
  cloud_init_file_path = "/var/lib/vz/snippets/${local.hostname}.yml"
}
