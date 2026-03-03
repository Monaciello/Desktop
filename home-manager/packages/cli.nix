# CLI tools
{ pkgs, ... }:
{
  home.packages = [
    pkgs.tmux
    pkgs.eza
    pkgs.bat
    pkgs.fzf
    pkgs.ripgrep
    pkgs.zoxide
    pkgs.btop
    pkgs.fastfetch
    pkgs.jq
    pkgs.yq
    pkgs.tree
  ];
}
