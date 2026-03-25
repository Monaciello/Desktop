# Shared flake input filter — used wherever we need flake-only attrs (registry, nixPath).
{ lib, inputs }: lib.filterAttrs (_: lib.isType "flake") inputs
