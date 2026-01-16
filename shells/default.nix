# Development shells - accessible via 'nix develop' or 'nix develop .#<name>'
#
# LAYER 3: PROJECT-LEVEL - These are for development work, NOT user/system config
#
# Available shells:
#   default - Bootstrap shell with nix, home-manager, git (for initial setup)
#   dev     - General development: python, uv, shellcheck, bats, nix tools
#   fhs     - FHS-compliant environment for running pre-compiled binaries
#   xonsh   - Xonsh shell with Python virtualenv and xontrib-vox
#
# Usage:
#   nix develop          # enters default shell
#   nix develop .#dev    # enters dev environment with python, shellcheck, etc
#   nix develop .#fhs    # enters FHS environment
#   nix develop .#xonsh  # enters xonsh dev environment
#
{pkgs}: {
  # Bootstrap shell for initial flake setup (legacy nix-shell compatible)
  default = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
    ];
  };

  # FHS environment for running pre-compiled Linux binaries
  # Useful for: AppImages, proprietary software, some game tools
  fhs =
    (pkgs.buildFHSEnv {
      name = "fhs";
      targetPkgs = pkgs:
        (with pkgs; [
          xonsh # single shell for everything
          pkgsi686Linux.glibc
          pkgsi686Linux.stdenv.cc.cc.lib
        ])
        ++ (with pkgs.xorg; [
          libX11
          libXcursor
          libXrandr
        ]);
      multiPkgs = pkgs: (with pkgs; [
        pkgsi686Linux.glibc
        pkgsi686Linux.stdenv.cc.cc.lib
      ]);
      runScript = "xonsh";
    }).env;
}
