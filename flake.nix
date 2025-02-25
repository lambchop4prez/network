{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    authentik-nix.url = "github:nix-community/authentik-nix";
  };

  outputs = inputs@{ self, nixpkgs, authentik-nix }:
  let
    darwinSystems = ["aarch64-darwin" "x86_64-darwin"];
    linuxSystems = ["aarch64-linux" "x86_64-linux"];
    allSystems = darwinSystems ++ linuxSystems;
    hosts = {
      # default = {
      #   system = "x86_64-linux";
      #   runtime = "qemu-vm";
      # };
      auth = {
        system = "x86_64-linux";
        runtime = "proxmox-lxc";
      };
      ca = {
        system = "x86_64-linux";
        runtime = "proxmox-lxc";
      };
    };
    hostnames = nixpkgs.lib.attrNames hosts;
  in
  {
    devShells = nixpkgs.lib.genAttrs allSystems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            opentofu
            zsh
          ];
          shellHook = ''
            exec zsh
          '';
        };
      }
    );
    nixosConfigurations = nixpkgs.lib.genAttrs hostnames (
      host: nixpkgs.lib.nixosSystem {
        # inherit host;
        # specialargs = inputs;
        system = hosts.${host}.system;
        modules = [
          ./hosts/${host}
          ./modules/${hosts.${host}.runtime}
          inputs.authentik-nix.nixosModules.default
        ];
      }
    );
  };
}
