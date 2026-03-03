# GUI applications — Linux packages; macOS equivalents come from Homebrew casks
{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [
    pkgs.tor-browser
    pkgs.vlc
    pkgs.obs-studio
    pkgs.libreoffice-qt6-fresh
    pkgs.obsidian
    pkgs.zathura
    pkgs.xournalpp
    pkgs.anki
    pkgs.discord
    pkgs.telegram-desktop
    pkgs.rofimoji
  ];
  programs.firefox.enable = true;
}
