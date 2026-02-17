{ pkgs }:
{
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
      targetPkgs =
        pkgs:
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
      multiPkgs =
        pkgs:
        (with pkgs; [
          pkgsi686Linux.glibc
          pkgsi686Linux.stdenv.cc.cc.lib
        ]);
      runScript = "xonsh";
    }).env;
}
