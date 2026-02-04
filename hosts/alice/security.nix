# Security, firewall, SSH
{ ... }:
{
  networking.firewall.enable = true;
  # Layered security: sudoers + firewall + fail2ban + SSH hardening
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
