# Shared settings imported by both NixOS and nix-darwin hosts
# Core = all hosts; optional = per-host as needed.
{ ... }:
{
  imports = [
    ./core
  ];
}
