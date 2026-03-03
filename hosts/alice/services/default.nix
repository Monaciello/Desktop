# System services
{ ... }:
{
  imports = [
    ./network.nix
    ./virt.nix
    ./ollama.nix
  ];

  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.man.enable = true;
}
