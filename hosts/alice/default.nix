# NixOS configuration for alice
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
    ./boot.nix
    ./nix.nix
    ./users.nix
    ./security.nix
    ./locale.nix
    ./packages.nix
    ./fonts.nix
    ./desktop
    ./hardware
    ./services
  ];
}
