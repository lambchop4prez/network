{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/virtualisation/qemu-guest-agent.nix"
  ];
  config.services.qemuGuest.enable = true;
  # services.openssh.enable = true;

  # boot.initrd.availableKernelModules =
  #   [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  # boot.initrd.kernelModules = [ ];
  # boot.kernelModules = [ "kvm-intel" ];
  # boot.extraModulePackages = [ ];

  # boot.kernelParams = [
  #   "console=tty1"
  #   "console=ttyS0,115200"
  # ];

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
}
