{ pkgs, ... }:
{
  home.packages = with pkgs; [
    sops
    age
    ssh-to-age
    python313
    shellcheck
    ruff
    black
    bats
    nixd
    nixfmt-rfc-style
    statix
    rust-analyzer
  ];
}
