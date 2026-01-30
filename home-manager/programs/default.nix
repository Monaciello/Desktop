# User programs
{ ... }:
{
  imports = [
    ./git.nix
    ./tmux.nix
  ];

  programs.home-manager.enable = true;
}
