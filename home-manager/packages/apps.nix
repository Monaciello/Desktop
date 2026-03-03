# GUI applications — Linux packages; macOS equivalents come from Homebrew casks
{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = with pkgs; [
    tor-browser
    vlc
    obs-studio
    libreoffice-qt6-fresh
    obsidian
    zathura
    xournalpp
    anki
    discord
    telegram-desktop
    rofimoji
  ];
  programs.firefox.enable = true;
}
