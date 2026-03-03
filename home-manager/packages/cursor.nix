# Cursor IDE — Nix package on Linux, Homebrew cask on macOS
{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ pkgs.cursor ];
}
