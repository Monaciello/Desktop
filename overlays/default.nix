# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory.
  # Use prev (not final) to avoid infinite recursion: final depends on this overlay.
  additions = _final: prev: import ../pkgs { pkgs = prev; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications =
    _final: prev:
    # Linux only: needs `rpi-imager-appimage` from additions (not defined on Darwin).
    prev.lib.optionalAttrs prev.stdenv.isLinux {
      # Wrapper: run with disk group so block device write works.
      # sg group -c "cmd": runs cmd with group; user must be in disk group (users.nix).
      rpi-imager = prev.runCommand "rpi-imager" { } ''
        mkdir -p $out/bin
        imager="${prev.rpi-imager-appimage}/bin/rpi-imager"
        printf '%s\n' '#!/usr/bin/env bash' \
          'exec sg disk -c "exec \"$imager\" \"$@\""' > $out/bin/rpi-imager
        substituteInPlace $out/bin/rpi-imager --replace '$imager' "$imager"
        chmod +x $out/bin/rpi-imager
      '';
    };

  # Cursor IDE from code-cursor-nix; built with our pkgs so we can fix deps
  code-cursor = inputs.code-cursor-nix.overlays.default;

  # Fix xorg deprecation warnings: code-cursor-nix/package.nix uses deprecated
  # xorg.libX11 etc. Override to use top-level libx11, libxkbfile, etc.
  cursor-xorg-fix = _final: prev: {
    cursor = prev.cursor.override {
      xorg = {
        libxkbfile = prev.libxkbfile;
        libX11 = prev.libx11;
        libXcomposite = prev.libxcomposite;
        libXdamage = prev.libxdamage;
        libXext = prev.libxext;
        libXfixes = prev.libxfixes;
        libXrandr = prev.libxrandr;
        libxcb = prev.libxcb;
        lndir = prev.lndir;
      };
    };
  };
}
