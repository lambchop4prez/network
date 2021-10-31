source "proxmox" "base-ubuntu-amd64" {
  proxmox_url = "https://gypsy.lan:8006/api2/json"
  username = "root@pam"#!packer"
  password = "WeHaveNothingToLoseButOurChains"
  #token = "899a48f1-d530-4dad-be81-72acaf8e1d3c}"
  iso_file = "local:iso/ubuntu-20.04.2-live-server-amd64.iso"
  http_directory = "cloud-init"
  ssh_username = "tom"
  ssh_certificate_file = "~/.ssh/id_ecdsa.pub"
  node = "gypsy"
  insecure_skip_tls_verify = true
}