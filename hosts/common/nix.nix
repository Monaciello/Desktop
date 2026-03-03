# Nix daemon settings shared across NixOS and nix-darwin
{
  config,
  lib,
  inputs,
  ...
}:
let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      builders-use-substitutes = true;
    };

    registry = lib.mapAttrs (_: flake: lib.mkDefault { inherit flake; }) flakeInputs;

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    optimise.automatic = true;
  };
}
