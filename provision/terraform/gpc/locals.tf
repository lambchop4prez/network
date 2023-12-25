locals {
  packer_privileges = [
    "VM.Clone",
    "VM.Config.Disk",
    "VM.Config.CPU",
    "VM.Config.Memory",
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.AllocateTemplate",
    "Sys.Modify",
    "VM.Config.Options",
    "VM.Allocate",
    "VM.Audit",
    "VM.Console",
    "VM.Config.CDROM",
    "VM.Config.Network",
    "VM.PowerMgmt",
    "VM.Config.HWType",
    "VM.Monitor",
    "VM.Clone",
    "VM.Config.Cloudinit",
    "SDN.Use",
  ]
  terraform_privileges = [
    "Datastore.AllocateSpace",
    "Datastore.Audit",
    "Pool.Allocate",
    "Sys.Audit",
    "VM.Allocate",
    "VM.Audit",
    "VM.Clone",
    "VM.Config.CDROM",
    "VM.Config.CPU",
    "VM.Config.Cloudinit",
    "VM.Config.Disk",
    "VM.Config.HWType",
    "VM.Config.Memory",
    "VM.Config.Network",
    "VM.Config.Options",
    "VM.Monitor",
    "VM.PowerMgmt",
    "Sys.Console",
    "Sys.Modify",
    "VM.Migrate",
    "SDN.Use",
  ]
}
