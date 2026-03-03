# Linux-only HM modules — Wayland desktop, GTK theming, screenshots
{ ... }:
{
  imports = [
    ./xdg.nix
    ./gtk.nix
    ./sway.nix
    ./waybar.nix
    ./rofi.nix
    ./flameshot.nix
  ];
}
