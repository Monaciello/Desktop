{ pkgs }:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;

  default = pkgs.mkShell {
    nativeBuildInputs = with pkgs; [
      home-manager
      git
      direnv
      pre-commit
      statix
      deadnix
    ];
    shellHook = ''
      pre-commit install --allow-missing-config 2>/dev/null || true
    '';
  };

  rust = pkgs.mkShell {
    strictDeps = true;
    nativeBuildInputs = with pkgs; [
      cargo
      rustc
      clippy
      rustfmt
      rust-analyzer
      pkg-config
    ];
    env.RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    env.RUST_BACKTRACE = "1";
  };

  oci = pkgs.mkShell {
    nativeBuildInputs = with pkgs; [
      oci-cli
      jq
      curl
    ];
  };

  linuxShells =
    if isLinux then {
      fhs =
        (pkgs.buildFHSEnv {
          name = "fhs";
          targetPkgs =
            pkgs:
            (with pkgs; [
              zsh
              pkgsi686Linux.glibc
              pkgsi686Linux.stdenv.cc.cc.lib
              libx11
              libxcursor
              libxrandr
            ]);
          multiPkgs =
            pkgs:
            (with pkgs; [
              pkgsi686Linux.glibc
              pkgsi686Linux.stdenv.cc.cc.lib
            ]);
          runScript = "zsh";
        }).env;
    }
    else
      { };
in
{
  inherit default rust oci;
} // linuxShells
