{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    git
  ];
  system.stateVersion = "25.05";
}
