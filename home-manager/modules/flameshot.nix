# Flameshot screenshot tool with grim adapter for Wayland/Sway
{ config, pkgs, ... }:
{
  home.packages = [ pkgs.flameshot ];

  # Flameshot configuration for Wayland (force = true avoids backup-file collision)
  xdg.configFile."flameshot/flameshot.ini" = {
    force = true;
    text = ''
    [General]
    drawColor=#800000
    savePath=${config.home.homeDirectory}/Pictures
    useGrimAdapter=true
    disabledTrayIcon=false
    showStartupLaunchMessage=false
  '';
  };
}
