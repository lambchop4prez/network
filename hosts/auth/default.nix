{authentik-nix, ...}:
{
  imports = [
    ../default
  ];
  virtualisation.diskSize = 8 * 1024;
  services.authentik = {
    # enable = true;
    # settings = {
    #   disable_startup_analytics = true;
    #   avatars = "initials";
    # };
  };
}
