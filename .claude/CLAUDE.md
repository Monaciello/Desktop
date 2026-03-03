# Project Constraints

Specific rules for this NixOS flake. See `AI.md` for general guardrails.

## Current Focus

Phase 4: OCI deployment. `nix flake check` passes. Next: `nixos-anywhere` against oci-claw once 1Password SSH agent confirmed live.

## File Ownership

@import ./modules/ownership.mdc

## Verification Required

@import ./modules/verification.mdc

## Package Placement

@import ./modules/placement.mdc

## Skarabox Pattern (Future)

@import ./modules/skarabox.mdc

## Commit Style

```
feat(scope): description
fix(scope): description
docs(scope): description
refactor(scope): description
```

Scopes: `hosts`, `home-manager`, `shells`, `flake`, `docs`

## Debugging Protocol — Nix Evaluation Warnings

@import ./modules/debugging.mdc

## Banned Actions

@import ./modules/banned.mdc
