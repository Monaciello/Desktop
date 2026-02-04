{ config, pkgs, ... }:
{
  # xonsh is defined at host level in hosts/alice/users.nix
  # Here we only manage the xonshrc config file
  home.file.".xonshrc".text = builtins.readFile ./dotfiles/xonshrc;

  # Create wallpapers directory for set_wallpaper function
  home.file."Pictures/wallpapers/.keep" = {
    text = "";
  };
}
