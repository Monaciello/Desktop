# Development tools
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Secrets management
    sops
    age
    ssh-to-age

    # Languages
    python3

    # Linting/testing
    shellcheck
    bats

    # Nix tools
    nixfmt
    statix

    # Neovim dependencies
    imagemagick
  ];
}
