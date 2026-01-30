# AI Assistant Guardrails

General guidelines for AI assistants. See `CLAUDE.md` for project-specific constraints.

## Verification Loop

Before any change is complete:
1. `git add` new files (flakes only see staged files)
2. `nix flake check`
3. `nixfmt --check <modified-files>`
4. `shellcheck <file>` for shell scripts
5. `selene -q <file>` for Lua files

Stop on failure. Analyze. Retry.

## Nix Gotchas

- **Git staging:** Flakes only see indexed files
- **Purity:** Flakes prohibit impure expressions by default
- **Module merging:** `lib.mkForce` overrides, `lib.mkDefault` sets fallback
- **Overlays:** Access unstable via `pkgs.unstable.<package>`
- **Option types:** `lib.types.str` disallows multiple defs, `lib.types.lines` merges

## No Hallucinated Options

Verify options exist:
- Search: https://search.nixos.org/options
- REPL: `nix repl --expr 'import <nixpkgs/nixos> {}'`
- Flake: `nix flake show`

## Recovery

```bash
sudo nixos-rebuild switch --rollback     # System
home-manager generations                  # List home generations
```

## ~/.config Management

| Path | Status |
|------|--------|
| `i3/`, `kitty/`, `nvim/`, `rofi/`, `picom/`, `tmux/` | Managed by home-manager |
| `git/`, `gtk-3.0/`, `gtk-4.0/` | Managed by home-manager |
| `sops/age/` | Manual (sensitive keys) |
| `btop/` | Unmanaged (consider adding) |
| `obs-studio/`, `obsidian/`, `discord/` | Unmanaged (app-managed) |

## ~/.claude Management

| Path | Manageable |
|------|------------|
| `settings.json` | Yes (currently `{}`) |
| `.credentials.json` | No (sensitive) |
| `projects/`, `history.jsonl` | No (dynamic) |

## Workflow

1. **Plan:** List files, risk level, steps, verification commands
2. **Execute:** Incremental changes, `git add` immediately
3. **Verify:** Full verification sequence, report results

## Self-Check

Before finalizing:
- Package/option verified to exist?
- File organization matches patterns?
- New files staged to git?
- Change is minimal and focused?
