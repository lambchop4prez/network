{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs }:
  let
    hosts = {
      default = {
        system = "x86_64-linux";
        runtime = "qemu-vm";
      };
      ca = {
        system = "x86_64-linux";
        runtime = "proxmox-lxc";
      };
    };
    hostnames = nixpkgs.lib.attrNames hosts;
  in
  {
    nixosConfigurations = nixpkgs.lib.genAttrs hostnames (
      host: nixpkgs.lib.nixosSystem {
        # inherit host;
        # specialargs = inputs;
        system = hosts.${host}.system;
        modules = [
          ./hosts/${host}
          ./modules/${hosts.${host}.runtime}
        ];
      }
    );
  };
}
