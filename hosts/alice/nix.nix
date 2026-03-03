# Nix and nixpkgs settings — alice-specific overrides on top of hosts/common
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
  nix = {
    settings.nix-path = config.nix.nixPath;
    channel.enable = false;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "rpi4-01";
        sshUser = "nix-builder";
        sshKey = "/root/.ssh/nix-builder";
        systems = [ "aarch64-linux" ];
        maxJobs = 2;
        speedFactor = 1;
        supportedFeatures = [ "nixos-test" ];
      }
    ];

    gc.dates = "weekly";
  };
}
