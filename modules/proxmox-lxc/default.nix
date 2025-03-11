# Initial config pulled from https://nixos.wiki/wiki/Proxmox_Linux_Container
{ config, modulesPath, pkgs, lib, nixos-generators, ... }:
{
  # imports = [
  #   nixos-generators.nixosModules.proxmox-lxc
  # ];
  # proxmox-lxc = {

  # };
  config.formats = ["proxmox-lxc"];
  nix.settings = { sandbox = false; };
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };
  security.pam.services.sshd.allowNullPassword = true;
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        PermitEmptyPasswords = "yes";
    };
  };
}
