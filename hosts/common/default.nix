# Shared settings imported by both NixOS and nix-darwin hosts
{ ... }:
{
  imports = [
    ./nix.nix
  ];
}
