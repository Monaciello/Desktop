# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: { };

  # Cursor IDE from code-cursor-nix; built with our pkgs so we can fix deps
  code-cursor = inputs.code-cursor-nix.overlays.default;

  # Fix xorg deprecation warnings: code-cursor-nix/package.nix uses deprecated
  # xorg.libX11 etc. Override to use top-level libx11, libxkbfile, etc.
  cursor-xorg-fix = final: prev: {
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

  # When applied, the unstable nixpkgs set will be accessible through 'pkgs.unstable'
  unstable = final: _prev: {
    unstable = import inputs.nixpkgs {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
