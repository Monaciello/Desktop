{ pkgs, ... }:
{
  home.packages = [
    pkgs.sops
    pkgs.age
    pkgs.ssh-to-age
    pkgs.python313
    pkgs.shellcheck
    pkgs.ruff
    pkgs.black
    pkgs.bats
    pkgs.nixd
    pkgs.nixfmt-rfc-style
    pkgs.statix
    pkgs.rust-analyzer
  ];
}
