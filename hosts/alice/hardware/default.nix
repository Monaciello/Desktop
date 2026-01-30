# Hardware configuration
{ ... }:
{
  imports = [
    ./bluetooth.nix
    ./power.nix
    ./ssd.nix
  ];
}
