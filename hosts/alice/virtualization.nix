# Cross-architecture support: QEMU binfmt for aarch64
#
# Lets alice evaluate and build aarch64-linux derivations locally.
# Slow (10-100x native) but functional for `nix flake check --all-systems`
# and development builds (e.g. RaspberryPi SD image).
{ ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
