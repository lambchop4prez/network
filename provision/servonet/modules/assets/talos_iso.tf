data "talos_image_factory_extensions_versions" "vm" {
  # get the latest talos version
  talos_version = var.talos_version
  filters = {
    names = [
      "amd-ucode",
      "amdgpu",
      "qemu-guest-agent",
    ]
  }
}
data "talos_image_factory_overlays_versions" "pi" {
  # get the latest talos version
  talos_version = var.talos_version
  filters = {
    name = "rpi_generic"
  }
}
resource "talos_image_factory_schematic" "vm" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.vm.extensions_info[*].name
        }
      }
    }
  )
}
resource "talos_image_factory_schematic" "pi" {
  schematic = yamlencode(
    {
      overlay = {
        image = data.talos_image_factory_overlays_versions.pi.overlays_info[0].image
        name  = "rpi_generic"
      }
    }
  )
}
output "schematics" {
  value = {
    vm = talos_image_factory_schematic.vm.id
    pi = talos_image_factory_schematic.pi.id
  }
}
