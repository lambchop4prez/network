{authentik-nix, ...}:
{
  imports = [
    ../default
  ];
  services.authentik = {
    # enable = true;
    # settings = {
    #   disable_startup_analytics = true;
    #   avatars = "initials";
    # };
  };
}
