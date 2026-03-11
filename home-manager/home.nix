# Home-manager configuration — shared across NixOS and macOS
{ lib, config, ... }:
{
  imports = [
    ./modules/shared.nix
    ./packages
    ./programs
  ];

  home = {
    username = "sasha";
    homeDirectory = lib.mkDefault "/home/sasha";
    stateVersion = "24.11";
  };

  # Lock zsh dotDir to legacy behavior (silence HM 26.05 warning)
  programs.zsh.dotDir = config.home.homeDirectory;
}
