# NixOS configuration for alice
{ ... }:
{
  imports = [
    ../common
    ./hardware-configuration.nix
    ./secrets.nix
    ./boot.nix
    ./nix.nix
    ./users.nix
    ./security.nix
    ./locale.nix
    ./packages.nix
    ./fonts.nix
    ./1password.nix
    ./virtualization.nix
    ./desktop
    ./hardware
    ./services
  ];
}
