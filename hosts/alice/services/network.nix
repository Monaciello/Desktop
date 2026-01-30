# Network services
{ ... }:
{
  networking.hostName = "alice";
  networking.networkmanager.enable = true;

  services.tailscale.enable = true;

  services.syncthing = {
    enable = true;
    user = "sasha";
    dataDir = "/home/sasha";
    configDir = "/home/sasha/.config/syncthing";
  };
}
