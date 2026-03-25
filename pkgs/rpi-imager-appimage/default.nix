# Upstream AppImage — recommended by rpi-imager maintainers for Linux.
# The nixpkgs package has Qt/Wayland issues on Sway; AppImage works with QT_QPA_PLATFORM=xcb.
# See: github.com/raspberrypi/rpi-imager/issues/1433
{ pkgs }:
let
  lib = pkgs.lib;
  pname = "rpi-imager";
  version = "2.0.6";
  src = pkgs.fetchurl {
    url = "https://github.com/raspberrypi/rpi-imager/releases/download/v${version}/Raspberry_Pi_Imager-v${version}-desktop-x86_64.AppImage";
    hash = "sha256-D2jYj+D0BkO7zrxwZ8teFrHSEMU53T4Rad1nQdX4kQw=";
  };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  profile = ''
    export QT_QPA_PLATFORM=xcb
  '';

  meta = {
    description = "Raspberry Pi Imaging Utility (AppImage)";
    homepage = "https://github.com/raspberrypi/rpi-imager/";
    license = lib.licenses.asl20;
    mainProgram = "rpi-imager";
    platforms = lib.platforms.linux;
  };
}
