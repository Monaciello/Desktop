# Convenience wrapper — imports everything (Linux-only; use shared.nix for cross-platform)
{ ... }:
{
  imports = [
    ./shared.nix
    ./linux.nix
  ];
}
