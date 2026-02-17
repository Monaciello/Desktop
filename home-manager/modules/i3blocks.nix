{ ... }:
{
  home.file.".config/i3/i3blocks.conf".source = ./dotfiles/i3blocks.conf;

  # i3blocks scripts
  home.file.".config/i3/scripts/battery" = {
    source = ./dotfiles/scripts/battery;
    executable = true;
  };
  home.file.".config/i3/scripts/cpu_usage" = {
    source = ./dotfiles/scripts/cpu_usage;
    executable = true;
  };
  home.file.".config/i3/scripts/volume" = {
    source = ./dotfiles/scripts/volume;
    executable = true;
  };
  home.file.".config/i3/scripts/network" = {
    source = ./dotfiles/scripts/network;
    executable = true;
  };
  home.file.".config/i3/scripts/disk" = {
    source = ./dotfiles/scripts/disk;
    executable = true;
  };
  home.file.".config/i3/scripts/datetime" = {
    source = ./dotfiles/scripts/datetime;
    executable = true;
  };
  home.file.".config/i3/scripts/application" = {
    source = ./dotfiles/scripts/application;
    executable = true;
  };
}
