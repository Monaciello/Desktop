# Custom packages — merged into pkgs via `overlays.additions` (see flake.nix).
#
# Build: nix build .#packages.<system>.<name>
#
# MCP servers (mcp-nixos, Serena): use the standalone flake — `nix run ./mcp#mcp-nixos-sandboxed`
{ pkgs }:
let
  inherit (pkgs) callPackage lib;
in
lib.optionalAttrs pkgs.stdenv.isLinux {
  # AppImage is Linux-only; avoids evaluating it on Darwin overlays.
  rpi-imager-appimage = callPackage ./rpi-imager-appimage { };
}
// {
  xontrib-uvox = callPackage ./xontrib-uvox { };
  python-backtrace = callPackage ./python-backtrace { };
}
