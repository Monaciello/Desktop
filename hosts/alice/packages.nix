# System packages
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim # TODO: remove after neovim fully configured
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
    pamixer # TODO: audit - may overlap with pipewire tools
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

    # GTK theming - TODO: consolidate with home-manager/modules/gtk.nix
    adapta-gtk-theme
    papirus-icon-theme

    # Virtualization - TODO: move to hosts/alice/services/virt.nix
    libvirt 
    qemu
    spice-vdagent
    virt-manager
    virt-viewer
  ];
}
