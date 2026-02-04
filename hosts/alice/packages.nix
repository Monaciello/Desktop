# System packages
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core utilities
    wget
    curl
    git

    # i3 and desktop
    i3
    i3status
    i3lock
    i3lock-fancy
    i3blocks
    rofi
    rofimoji
    picom
    feh
    stalonetray
    arandr
    autorandr
    lxappearance
    numlockx

    # Audio/Media
    brightnessctl
    playerctl
    pulseaudio

    # Screenshots
    flameshot

    # Clipboard
    xclip

    # X11 tools
    acpi
    sysstat
    xdotool
    xorg.xdpyinfo
    xorg.xprop
    xorg.xrandr

    # Keyboards
    keymapp # ZSA keyboard configuration GUI
    wally-cli # ZSA firmware flasher

    # Fallback desktop environment
    xfce.xfce4-panel
    xfce.xfce4-settings
    xfce.xfce4-session
    xfce.xfce4-terminal
    xfce.thunar
  ];
}
