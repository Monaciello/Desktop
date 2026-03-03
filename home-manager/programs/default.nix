# User programs
{ ... }:
{
  imports = [
    ./git.nix
    ./ssh.nix
    ./tmux.nix
  ];

  programs.home-manager.enable = true;
}
