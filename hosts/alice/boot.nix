# Boot configuration
{ ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.initrd.luks.devices."luks-92570add-ebcc-47da-917b-baea70fab43d".device =
    "/dev/disk/by-uuid/92570add-ebcc-47da-917b-baea70fab43d";

  system.stateVersion = "24.11";
}
