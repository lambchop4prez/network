{authentik-nix, agenix, secrets, ...}:
let user = "tmc"; in
{
  imports = [
    ../default
  ];
  age.identityPaths = [
    "/home/${user}/.ssh/id_ed25519"
  ];
  age.secrets."authentik-env" = {
    symlink = true;
    path = "/run/secrets/authentik/authentik-env";
    file = "${secrets}/authentik-env.age";
    mode = "600";
    owner = "authentik";
    group = "wheel";
  };
  virtualisation.diskSize = 8 * 1024;
  services.authentik = {
    environmentFile = "/run/secrets/authentik/authentik-env";

    enable = true;
    settings = {
      disable_startup_analytics = true;
      avatars = "initials";
    };
  };
}
