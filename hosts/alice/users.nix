# User definitions
{ config, pkgs, ... }:
let
  xonsh = pkgs.xonsh.override {
    extraPackages = ps: [
      pkgs.xontrib-uvox
      pkgs.xontrib-bashisms
      pkgs.xontrib-readable-traceback
    ];
  };
in
{
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
    shell = xonsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgoYdp8IORl7zx130albZSo41PJRPARjZLSTeo2eQqa tahgijones@gmail.com"
    ];
  };
}
