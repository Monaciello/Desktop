# Virtualization (KVM/QEMU)
{ pkgs, ... }:
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    libvirt
    qemu
    spice-vdagent
    virt-viewer
  ];
}
