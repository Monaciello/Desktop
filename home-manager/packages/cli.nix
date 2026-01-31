# CLI tools
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # File manager
    lf

    # Terminal (kitty managed by programs.kitty in modules/kitty.nix)
    tmux

    # Modern CLI replacements
    eza # ls replacement
    bat # cat replacement
    fzf # fuzzy finder
    ripgrep # grep replacement
    zoxide # cd replacement
    btop # htop replacement
    fastfetch # system info

    # Utilities
    jq
    yq
    tree
  ];
}
