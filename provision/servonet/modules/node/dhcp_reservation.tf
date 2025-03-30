data "opnsense_kea_subnet" "lan" {
  id = var.opnsense_lan_subnet
}

resource "opnsense_kea_reservation" "test" {
  subnet_id = data.opnsense_kea_subnet.lan.id

  ip_address  = var.ipv4_address
  mac_address = var.mac_address
  hostname    = var.hostname

  description = "Servonet Node ${var.hostname}"
}
