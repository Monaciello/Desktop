# System services
{ ... }:
{
  imports = [
    ./network.nix
    ./virt.nix
  ];

  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.man.enable = true;
}
