{ ... }:
{
  # xonsh is defined at host level in hosts/alice/users.nix
  # Here we only manage the xonshrc config file
  home.file.".xonshrc".source = ./dotfiles/xonshrc;

}
