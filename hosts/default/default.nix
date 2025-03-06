{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    git
    vim
  ];
  system.stateVersion = "25.05";
}
