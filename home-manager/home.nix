# Home-manager configuration
{ ... }:
{
  imports = [
    ./modules/all.nix
    ./packages
    ./programs
  ];

  # Allow unfree packages (like Obsidian, VSCodium extensions, etc.)
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "sasha";
    homeDirectory = "/home/sasha";
    stateVersion = "24.11";
  };

  systemd.user.startServices = "sd-switch";
}
