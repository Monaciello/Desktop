# Home-manager configuration — shared across NixOS and macOS
{ lib, ... }:
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
}
