# Cross-platform HM modules — imported on both NixOS and macOS
{ ... }:
{
  imports = [
    ./cursor-rules.nix
    ./continue.nix
    ./kitty.nix
    ./neovim.nix
    ./lf.nix
    ./zsh.nix
  ];
}
