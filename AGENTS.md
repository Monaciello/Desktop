# Desktop — Agent Context

NixOS (alice) + nix-darwin (macbook), home-manager. See root `AGENTS.md` for cross-repo context.

## Structure

- `hosts/alice/` — NixOS system config
- `hosts/macbook/` — nix-darwin
- `home-manager/modules/` — user dotfiles (Sway, neovim, zsh, etc.)
- `overlays/` — package modifications

## Specs

- `Desktop/.ai/templates/spec.md` — Use for features spanning 3+ files

## Key Paths

- SSH: `home-manager/programs/ssh.nix` — nuc, rpi4-01, oci-claw
- Cursor rules: `home-manager/modules/dotfiles/cursor-rules/`
