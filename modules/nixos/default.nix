# Reusable NixOS modules exported by this flake.
#
# PURPOSE: Modules here are for SHARING with other flakes or upstreaming.
# Your personal host config belongs in hosts/<hostname>/, NOT here.
#
# WHEN TO USE:
#   - You've written a generic module others could use
#   - You want to share config between multiple machines via flake inputs
#   - You're preparing something for nixpkgs contribution
#
# CURRENTLY EMPTY: All your NixOS config is in hosts/alice/default.nix
# This is fine for a single-machine setup. No need to refactor unless
# you add more hosts or want to share modules.
#
# Usage from other flakes:
#   inputs.your-flake.nixosModules.example
#
# Example module (in ./example.nix):
#   { config, lib, pkgs, ... }: {
#     options.services.example.enable = lib.mkEnableOption "example";
#     config = lib.mkIf config.services.example.enable { ... };
#   }
{
  # example = import ./example.nix;
}
