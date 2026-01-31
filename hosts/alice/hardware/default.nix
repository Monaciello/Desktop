# Hardware configuration
{ ... }:
{
  imports = [
    ./bluetooth.nix
    ./keyboard.nix
    ./power.nix
    ./ssd.nix
  ];
}
