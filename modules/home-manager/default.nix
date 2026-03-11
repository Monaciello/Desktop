# Reusable home-manager modules exported by this flake.
#
# PURPOSE: Modules here are for SHARING with other flakes or upstreaming.
# Your personal home config belongs in home-manager/home.nix and
# home-manager/modules/, NOT here.
#
# WHEN TO USE:
#   - You've written a generic HM module others could use
#   - You want to share home config between users/machines via flake inputs
#   - You're preparing something for home-manager contribution
#
# CURRENTLY EMPTY: All your home-manager config is in:
#   - home-manager/home.nix (main user config)
#   - home-manager/modules/ (Sway, kitty, neovim, etc.)
# This is the correct place for personal config.
#
# Usage from other flakes:
#   inputs.your-flake.homeManagerModules.example
#
# Example module (in ./example.nix):
#   { config, lib, pkgs, ... }: {
#     options.programs.example.enable = lib.mkEnableOption "example";
#     config = lib.mkIf config.programs.example.enable { ... };
#   }
{
  # example = import ./example.nix;
}
