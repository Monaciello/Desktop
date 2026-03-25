{ pkgs }:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;

  default = pkgs.mkShell {
    nativeBuildInputs = [
      pkgs.home-manager
      pkgs.git
      pkgs.direnv
      pkgs.pre-commit
      pkgs.statix
      pkgs.deadnix
    ];
    shellHook = ''
      pre-commit install --allow-missing-config 2>/dev/null || true
    '';
  };

  rust = pkgs.mkShell {
    strictDeps = true;
    nativeBuildInputs = [
      pkgs.cargo
      pkgs.rustc
      pkgs.clippy
      pkgs.rustfmt
      pkgs.rust-analyzer
      pkgs.pkg-config
    ];
    env.RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    env.RUST_BACKTRACE = "1";
  };

  oci = pkgs.mkShell {
    nativeBuildInputs = [
      pkgs.oci-cli
      pkgs.jq
      pkgs.curl
    ];
  };

  linuxShells =
    if isLinux then
      {
        fhs =
          (pkgs.buildFHSEnv {
            name = "fhs";
            targetPkgs = p: [
              p.zsh
              p.pkgsi686Linux.glibc
              p.pkgsi686Linux.stdenv.cc.cc.lib
              p.libx11
              p.libxcursor
              p.libxrandr
            ];
            multiPkgs = p: [
              p.pkgsi686Linux.glibc
              p.pkgsi686Linux.stdenv.cc.cc.lib
            ];
            runScript = "zsh";
          }).env;
      }
    else
      { };
in
{
  inherit default rust oci;
}
// linuxShells
