# Network services
{ ... }:
{
  networking.hostName = "alice";
  networking.networkmanager.enable = true;

  services.tailscale.enable = true;

  services.syncthing = {
    enable = true;
    user = "sasha";
    dataDir = "/home/sasha/Sync";
    configDir = "/home/sasha/.config/syncthing";
  };

  systemd.services.syncthing.serviceConfig = {
    ProtectSystem = "strict";
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
  };
}
