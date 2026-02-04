# Import all home-manager modules
{
  imports = [
    # Theme & Colors (colors defined in gtk.nix)
    ./gtk.nix
    ./wallpaper.nix

    # Window Manager & Desktop
    ./i3.nix
    ./i3blocks.nix
    ./picom.nix
    ./rofi.nix
    ./stalonetray.nix

    # Applications & Tools
    ./kitty.nix
    ./neovim.nix
    ./lf.nix
    ./xonsh.nix
  ];
}
