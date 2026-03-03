# Home-manager — Linux-specific modules (Sway, Waybar, GTK, etc.)
{ ... }:
{
  imports = [
    ./modules/linux.nix
  ];

  home.homeDirectory = "/home/sasha";

  systemd.user.startServices = "sd-switch";
}
