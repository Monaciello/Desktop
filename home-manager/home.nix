# Home-manager configuration
{ ... }:
{
  imports = [
    ./modules/all.nix
    ./packages
    ./programs
  ];

  home = {
    username = "sasha";
    homeDirectory = "/home/sasha";
    stateVersion = "24.11";
  };

  systemd.user.startServices = "sd-switch";
}
