{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3223f903-2765-49f6-86bc-41e4dc0adf0a";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-8cee8979-ec7b-4ed8-8c5a-a373839a34dd".device =
    "/dev/disk/by-uuid/8cee8979-ec7b-4ed8-8c5a-a373839a34dd";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B25C-3BA8";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/86ef263a-df63-4567-94e8-51451801b1c7"; }
  ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
