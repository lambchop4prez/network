{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    step-cli
    step-ca
  ];
}
