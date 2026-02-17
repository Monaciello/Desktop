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
    telegram-desktop

    # Desktop tools
    rofimoji

  ];
  programs.firefox.enable = true;
}
