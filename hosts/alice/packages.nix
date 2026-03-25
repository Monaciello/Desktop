{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rpi-imager
    wget
    curl
    git
    swayidle
    kanshi
    wtype
    wlr-randr
    mako
    wdisplays
    flameshot
    acpi
    sysstat
    keymapp
  ];
}
