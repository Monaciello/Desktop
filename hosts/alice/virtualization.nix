# Cross-architecture support: QEMU binfmt for aarch64
#
# Lets alice evaluate and build aarch64-linux derivations locally.
# Slow (10-100x native) but functional for `nix flake check --all-systems`
# and development builds. Native speed comes from the rpi4-01 remote
# builder configured in nix.nix.
{ ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
