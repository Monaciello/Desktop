# Desktop environment
{ ... }:
{
  imports = [
    ./xserver.nix
    ./audio.nix
    ./portal.nix
  ];
}
