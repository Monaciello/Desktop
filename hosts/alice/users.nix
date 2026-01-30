# User definitions
{ pkgs, ... }:
let
  xonUvox = pkgs.xonsh.override {
    extraPackages = ps: [ pkgs.xontrib-uvox ];
  };
in
{
  users.users.sasha = {
    uid = 1000;
    isNormalUser = true;
    description = "sasha";
    hashedPassword = "$6$D310RvwPyv5ZIocG$eG83A0Dt7bRdHMrRK29wk8PEFLcLw5dTnC1N0b8/ODKHc.UmbMlaQE///o4SUHB3vQ4wrKx/L5IkiU6YFzrw01";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    shell = xonUvox;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgoYdp8IORl7zx130albZSo41PJRPARjZLSTeo2eQqa tahgijones@gmail.com"
    ];
  };
}
