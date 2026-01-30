# Project Constraints

Specific rules for this NixOS flake. See `AI.md` for general guardrails.

## Current Focus

Phase 3: Documentation cleanup and build validation. No new features until `nix flake check` passes.

## File Ownership

| Path | Owner | Notes |
|------|-------|-------|
| `flake.nix` | Ask first | Core structure |
| `flake.lock` | Never touch | Use `nix flake update` |
| `hosts/alice/hardware-configuration.nix` | Never touch | Generated |
| `hosts/alice/*.nix` | May modify | System config |
| `home-manager/**` | May modify | User config |
| `shells/` | May modify | Dev environments |
| `*.yaml` in secrets | Never touch | Encrypted |

## Verification Required

Before declaring any change complete:

```bash
git add <new-files>
nix flake check
nixfmt --check <modified-files>
```

## Package Placement

```
System service/daemon  -> hosts/alice/services/*.nix
System package         -> hosts/alice/packages.nix
User GUI app          -> home-manager/packages/apps.nix
User CLI tool         -> home-manager/packages/cli.nix
Dev tool              -> shells/default.nix
Font                  -> hosts/alice/fonts.nix
```

## Skarabox Pattern (Future)

When integrating skarabox, follow `nix-starter-configs-skarabox` pattern:

```
<hostname>/
├── configuration.nix    # References secrets, NOT encrypted
├── secrets.yaml         # Encrypted with BOTH host + main keys
├── facter.json
├── hostid
├── host_key.pub
├── ssh.pub
├── ip
├── ssh_port
└── ssh_boot_port
```

SOPS dual-key structure:
```yaml
keys:
  - &hostname age1<from-host-key>
  - &main age1<personal-key>
creation_rules:
  - path_regex: <hostname>/secrets.yaml
    key_groups:
      - age:
          - *hostname
          - *main
```

## Commit Style

```
feat(scope): description
fix(scope): description
docs(scope): description
refactor(scope): description
```

Scopes: `hosts`, `home-manager`, `shells`, `flake`, `docs`

## Banned Actions

- Adding `--impure` without documenting why
- Modifying files outside scope constraints
- Committing unencrypted secrets
- Using `lib.mkForce` without justification
- Creating new hosts without approval
