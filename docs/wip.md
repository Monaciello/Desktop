# WIP - Sprint Tracker

Daily sprint log. Max 80 lines. Rotate weekly.

## Active TODOs

**Phase 6: Skarabox migration - 2026-02-10**

| Status | Item | Where |
|--------|------|-------|
| DONE | Full codebase audit | — |
| DONE | Pass nix flake check + nixfmt | — |
| DONE | **1. Add flake-parts, wrap outputs** | skarabox/migration.md |
| DONE | **2. Set up SOPS dual-key** | skarabox/migration.md |
| DONE | **3. Populate secrets + move hashedPassword** | skarabox/migration.md |
| N/A | **4. Generate host metadata** | skarabox-host only, not alice |
| N/A | **5. Add nixos-facter** | skarabox-host only, not alice |
| DONE | **6. Drop standalone homeConfigurations** | skarabox/migration.md |
| DONE | Enable inputs + deploy-rs | skarabox/migration.md |
| DONE | Remove redundant nixos-facter-modules input | skarabox/migration.md |
| TODO | Add first skarabox server host | skarabox/setup-instructions.md |

**Phase 7: Pre-deployment config review - 2026-02-14**

| Status | Item | Where |
|--------|------|-------|
| TODO | Review i3 + i3blocks config | home-manager/modules/i3*.nix |
| TODO | Review tmux config | home-manager/modules/dotfiles/ |
| TODO | Review neovim (init.lua) | home-manager/modules/dotfiles/init.lua |
| TODO | Review picom config | home-manager/modules/picom.nix |
| TODO | Review xonshrc | home-manager/modules/dotfiles/xonshrc |
| TODO | Audit keybindings across all programs | — |
| TODO | Define VLAN topology (MGMT/PUBLIC/PRIVATE) | docs/skarabox-deployment-guide.md#Section-4 |
| TODO | Design roles/services/networking per host | modules/roles/ |

**Phase 8: Skarabox NUC deployment - From deployment guide**

| Status | Item | Reference |
|--------|------|-----------|
| TODO | 1. Design trust zones (whiteboard) | Vol3 §13 step 1 |
| TODO | 2. Generate host entry for NUC | Vol3 §13 step 3 |
| TODO | 3. Write custom modules (Vol 1-2 types) | Vol3 §13 step 5 |
| TODO | 4. Write role modules (SHB + custom) | Vol3 §13 step 6 |
| TODO | 5. Create SOPS secrets for NUC | Vol3 §13 step 7 |
| TODO | 6. Build beacon ISO | Vol3 §13 step 8 |
| TODO | 7. Test in VM | Vol3 §13 step 9 |
| TODO | 8. Flash beacon to USB, boot target | Vol3 §13 step 10 |
| TODO | 9. Install NixOS on target | Vol3 §13 step 11 |
| TODO | 10. Unlock encrypted root | Vol3 §13 step 12 |
| TODO | 11. Deploy full config | Vol3 §13 step 13 |
| TODO | 12. Verify SHB services | Vol3 §13 step 14 |
| TODO | 13. Verify custom monitoring | Vol3 §13 step 15 |
| TODO | 14. Test backup + restore | Vol3 §13 step 16 |
| TODO | 15. Test full recovery (wipe + reinstall) | Vol3 §13 step 17 |

## Reference Docs (converted 2026-02-14)

- `docs/nix-types-vol2-extended-recipes.md` — DNS, backups, cron/timers, certs, diagnostics
- `docs/nix-types-networking-reference.md` — Type system reference for infrastructure
- `docs/skarabox-deployment-guide.md` — Complete deployment guide (18-step checklist)

## Applied Fixes (2026-02-06)

- Commented out unused flake inputs (nixos-generators, nixos-anywhere, flake-parts)
- Fixed nixfmt → nixfmt-rfc-style (flake.nix + dev.nix)
- Deleted nixpkgs.nix (dead code)
- Fixed shells/default.nix comment (2 shells, not 4)
- Removed unused inputs from 8 modules + gtk.nix + neovim.nix
- Fixed all.nix missing function signature
- Created colors.nix (Catppuccin Mocha) — wired into kitty, gtk, stalonetray
- Added rofimoji to apps.nix
- Fixed xonsh: --oneline typo, nm→wifi, ip→myip, d→disp
- Removed dead jetbrains-mono comment from fonts.nix

## Integration Patterns

**Terminal**: kitty→tmux→nvim via vim-tmux-navigator (C-h/j/k/l)

**Clipboard**: tmux `y` → xclip, xonsh `xc` alias, nvim `clipboard=unnamedplus`

**Launcher**: i3 → Alt+s (rofi/apps), Alt+c (rofimoji)

**Dev**: nvim telescope (C-o find files), harpoon (leader+m menu), obsidian (Win+o)

**Theme**: Catppuccin Mocha via `home-manager/modules/colors.nix`