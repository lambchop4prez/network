terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
  
  required_version = ">= 0.12"
}

provider "proxmox" {
  pm_api_url = "https://gypsy:8006/api2/json"
}