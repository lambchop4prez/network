{pkgs, ...}:
{
  imports = [
    ../default
  ];
  environment.systemPackages = with pkgs; [
    step-cli
    step-ca
  ];
  services.step-ca = {
    enable = true;
    openFirewall = true;
    address = "0.0.0.0";
    port = 443;
    intermediatePasswordFile = "/run/keys/smallstep-password";
    settings = {

    }; # TODO
  };
}
