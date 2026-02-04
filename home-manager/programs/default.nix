# User programs
{ ... }:
{
  imports = [
    ./git.nix
    ./tmux.nix
    ./zsa
  ];

  programs.home-manager.enable = true;
}
