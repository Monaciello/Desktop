# Flameshot screenshot tool with grim adapter for Wayland/Sway
{ config, pkgs, ... }:
{
  home.packages = [ pkgs.flameshot ];

  # Flameshot configuration for Wayland
  xdg.configFile."flameshot/flameshot.ini".text = ''
    [General]
    drawColor=#800000
    savePath=${config.home.homeDirectory}/Pictures
    useGrimAdapter=true
    disabledTrayIcon=false
    showStartupLaunchMessage=false
  '';
}
