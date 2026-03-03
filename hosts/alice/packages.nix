{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    swaylock
    swayidle
    kanshi
    wl-clipboard
    wtype
    wlr-randr
    grim
    slurp
    rofi
    mako
    wdisplays
    brightnessctl
    playerctl
    flameshot
    acpi
    sysstat
    keymapp
  ];
}
