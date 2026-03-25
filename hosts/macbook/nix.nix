# Nix daemon settings — align developer ergonomics with `hosts/alice/nix.nix`
{
  config,
  lib,
  inputs,
  ...
}:
let
  flakeInputs = import ../common/flake-inputs.nix { inherit lib inputs; };
in
{
  nix = {
    settings = {
      nix-path = config.nix.nixPath;
      trusted-users = [
        "root"
        "sasha"
      ];
    };
    channel.enable = false;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };
}
