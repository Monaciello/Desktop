# Custom packages - accessible via 'nix build .#<name>' or 'nix shell .#<name>'
#
# Structure: Create a subdirectory per package with default.nix
#   pkgs/
#   ├── default.nix        (this file - aggregates all packages)
#   └── my-tool/
#       └── default.nix    (package definition)
#
_pkgs: {
  # xontrib packages removed — shell migrated to zsh
}
