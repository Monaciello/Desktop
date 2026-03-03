# User definitions
{ config, pkgs, ... }:
{
  users.mutableUsers = false;

  users.users.sasha = {
    uid = 1000;
    isNormalUser = true;
    description = "sasha";
    hashedPasswordFile = config.sops.secrets."user-password".path;
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgoYdp8IORl7zx130albZSo41PJRPARjZLSTeo2eQqa tahgijones@gmail.com"
    ];
  };

  programs.zsh.enable = true;
}
