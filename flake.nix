{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    authentik-nix.url = "github:nix-community/authentik-nix";
    agenix.url = "github:ryantm/agenix";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/lambchop4prez/secrets.git";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [
          "aarch64-darwin"
          "x86_64-linux"
        ];
        perSystem =
          {
            config,
            system,
            pkgs,
            ...
          }:
          {
            devShells.default =
              with pkgs;
              mkShell {
                packages = [
                  age
                  fluxcd
                  gum
                  helmfile
                  just
                  kubectl
                  kubernetes-helm
                  minijinja
                  sops
                  talosctl
                  talhelper

                ];
              };
          };
      }
    );

  #   outputs = inputs@{ self, nixpkgs, agenix, authentik-nix, systems, flake-utils, nixos-generators, secrets, ... }:
  #   let
  #     darwinSystems = ["aarch64-darwin" "x86_64-darwin"];
  #     linuxSystems = ["aarch64-linux" "x86_64-linux"];
  #     allSystems = darwinSystems ++ linuxSystems;
  #     hosts = {
  #       auth = {
  #         system = "x86_64-linux";
  #         format = "proxmox-lxc";
  #       };
  #       ca = {
  #         system = "x86_64-linux";
  #         format = "proxmox-lxc";
  #       };
  #       netboot = {
  #         system = "x86_64-linux";
  #         format = "proxmox-lxc";
  #       };
  #     };
  #     hostnames = nixpkgs.lib.attrNames hosts;
  #   in
  #   {
  #       flake-utils.lib.eachDefaultSystem (system:
  #       let pkgs = nixpkgs.legacyPackages.${system}; in
  #       {
  #         packages = rec {
  #           hello = pkgs.hello;
  #           default = hello;
  #         };
  #         apps = rec {
  #           hello = flake-utils.lib.mkApp { drv = self.packages.${system}.hello; };
  #           default = hello;
  #         };
  #       }
  #     );
  # flake-utils.lib.eachDefaultSystem(system:
  #     let
  #       pkgs = import nixpkgs {
  #         inherit system;
  #       };
  #     in
  #     {
  #       devShells.default = pkgs.mkShell {
  #
  #     }
  # );V
  #     # hosts = nixpkgs.lib.genAttrs hostnames (
  #     #   host: nixos-generators.nixosGenerate {
  #     #     # inherit host;
  #     #     specialArgs = {
  #     #       inputs = inputs;
  #     #     };
  #     #     system = hosts.${host}.system;
  #     #     format = "${hosts.${host}.format}";
  #     #     modules = [
  #     #       ./hosts/${host}
  #     #       # ./modules/${hosts.${host}.runtime}
  #     #       authentik-nix.nixosModules.default
  #     # );
  #     #     ];
  #     #   }
  #     # );
  #   };
}
