# Custom packages - accessible via 'nix build .#<name>' or 'nix shell .#<name>'
#
# This directory is for packages that:
#   - Are not in nixpkgs (custom software you maintain)
#   - Need patches/modifications beyond what overlays provide
#   - Are local tools specific to your workflow
#
# Structure: Create a subdirectory per package with default.nix
#   pkgs/
#   ├── default.nix        (this file - aggregates all packages)
#   ├── my-tool/
#   │   └── default.nix    (package definition)
#   └── patched-app/
#       └── default.nix
#
# Candidates to move here (if needed):
#   - Custom i3blocks scripts packaged as derivations
#   - Patched versions of packages (better in overlays/modifications though)
#   - Local scripts you want available via 'nix shell .#script-name'
#
# For now: Keep packages in environment.systemPackages (hosts/alice)
# or home.packages (home-manager/home.nix) unless you need them
# as standalone buildable/installable units.
#
pkgs: rec {
  xontrib-uvox = pkgs.callPackage ./xontrib-uvox { inherit (pkgs) uv; };
  xontrib-bashisms = pkgs.callPackage ./xontrib-bashisms { };
  python-backtrace = pkgs.callPackage ./python-backtrace { };
  xontrib-readable-traceback = pkgs.callPackage ./xontrib-readable-traceback {
    inherit python-backtrace;
  };
}
