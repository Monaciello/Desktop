# Font packages
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    cascadia-code
    font-awesome
    powerline-fonts
    powerline-symbols
    jetbrains-mono
  ];
}
