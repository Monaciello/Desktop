# Security, firewall, SSH
{ ... }:
{
  networking.firewall.enable = true;
  # TODO(security): add layered controls, fail2ban, firewall rules
  security = {
    sudo.enable = true;
    sudo.wheelNeedsPassword = false; # FIXME(security): require password after initial setup
    rtkit.enable = true;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
}
