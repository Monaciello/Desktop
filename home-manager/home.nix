# Home-manager configuration — shared across NixOS and macOS
{ lib, config, ... }:
{
  imports = [
    ./modules/shared.nix
    ./packages
    ./programs
  ];

  home = {
    username = "sasha";
    homeDirectory = lib.mkDefault "/home/sasha";
    stateVersion = "26.05";
  };

  # Keep dotfiles at ~/.zshrc etc. (HM 26.05+ default would use XDG under ~/.local/state)
  programs.zsh.dotDir = config.home.homeDirectory;
}
