provider "matchbox" {
  endpoint    = "matchbox.example.com:8081"
  client_cert = file("~/.matchbox/client.crt")
  client_key  = file("~/.matchbox/client.key")
  ca          = file("~/.matchbox/ca.crt")
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    matchbox = {
      source  = "poseidon/matchbox"
      version = "0.5.4"
    }
  }
}
