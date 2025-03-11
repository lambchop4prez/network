{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    authentik-nix.url = "github:nix-community/authentik-nix";
    agenix.url = "github:ryantm/agenix";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/lambchop4prez/secrets.git";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, agenix, authentik-nix, nixos-generators, secrets }:
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
        format = "proxmox-lxc";
      };
      ca = {
        system = "x86_64-linux";
        format = "proxmox-lxc";
      };
      # netboot = {
      #   system = "x86_64-linux";
      #   format = "proxmox-lxc";
      # };
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
            age
            age-plugin-yubikey
            zsh
            go-task
          ];
          shellHook = ''
            exec zsh
          '';
        };
      }
    );
    packages.x86_64-linux = nixpkgs.lib.genAttrs hostnames (
      host: nixos-generators.nixosGenerate {
        # inherit host;
        # specialargs = inputs;
        system = hosts.${host}.system;
        format = "${hosts.${host}.format}";
        modules = [
          ./hosts/${host}
          # ./modules/${hosts.${host}.runtime}
          authentik-nix.nixosModules.default
          agenix.nixosModules.default
        ];
      }
    );
  };
}
