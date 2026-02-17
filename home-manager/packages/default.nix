# User packages
{ ... }:
{
  imports = [
    ./cli.nix
    ./apps.nix
    ./dev.nix
    ./vscodium.nix
    ./cursor.nix
  ];
}
