# GUI applications
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Browsers
    tor-browser

    # Media
    vlc
    obs-studio

    # Office
    libreoffice-qt6-fresh
    obsidian
    zathura
    xournalpp
    anki

    # Communication
    discord

    # Development
    vscodium-fhs
  ];
}
