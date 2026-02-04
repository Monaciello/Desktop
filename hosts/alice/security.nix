# Security, firewall, SSH
{ ... }:
{
  networking.firewall.enable = true;
  # TODO(security): add layered controls, fail2ban, firewall rules
  security = {
    sudo.enable = true;
    sudo.wheelNeedsPassword = true;
    rtkit.enable = true;
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "10m";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "48h";
    };
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
}
