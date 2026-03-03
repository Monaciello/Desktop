# Project Constraints

Specific rules for this NixOS flake. See `AI.md` for general guardrails.

## Current Focus

Phase 4: OCI deployment. `nix flake check` passes. Next: `nixos-anywhere` against oci-claw once 1Password SSH agent confirmed live.

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

Before declaring any change complete — **in this order**:

```bash
git add -A                        # MUST stage first — Nix evaluates git tree,
                                  # stale store paths mask your actual edits
nix flake check 2>&1 | grep -v "^warning: Git"
nixfmt --check <modified-files>
```

**SSH / 1Password rule**: SSH keys live in 1Password, never on disk. The agent
config at `~/.config/1Password/ssh/agent.toml` must include the correct vaults
(currently: infra, Private, Personal). SSH commands will silently fail with
`Permission denied` unless `~/.1password/agent.sock` is live, 1Password GUI is
running, and `SSH_AUTH_SOCK` is set. Always verify:
```bash
export SSH_AUTH_SOCK=~/.1password/agent.sock
ssh-add -l   # must list "OCI ssh" key before any ssh/nixos-anywhere invocation
```
**OCI note**: The oci-claw instance uses the "OCI ssh" key from the 1Password
infra vault. The old `sasha@alice` key is lost — do not reference it.

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

## Debugging Protocol — Nix Evaluation Warnings

When `nix flake check` emits evaluation warnings:

1. **Stage first**: `git add -A` — warnings from stale store paths are misleading
2. **Isolate source**: check `homeConfigurations` and `nixosConfigurations` separately
   ```bash
   nix eval '.#homeConfigurations."sasha@alice".activationPackage' 2>&1 | grep "warning"
   nix eval '.#nixosConfigurations.alice.config.system.build.toplevel' 2>&1 | grep "warning"
   ```
3. **Trace to file**: use `nix eval --raw 'nixpkgs#path'` then `rg` in the nixpkgs store
4. **Classify before fixing**:
   - Our code → fix directly
   - Upstream nixpkgs derivation → `lib.warn` fires at evaluation time, overlays
     **cannot** intercept it; document as upstream TODO and file PR
   - Do NOT attempt >1 overlay strategy without first confirming where `lib.warn` is called

## Banned Actions

- Adding `--impure` without documenting why
- Modifying files outside scope constraints
- Committing unencrypted secrets
- Using `lib.mkForce` without justification
- Creating new hosts without approval
- Declaring a warning "transitive/upstream" without actually tracing it to a file first
