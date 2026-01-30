# WIP - Sprint Tracker

Daily sprint log. Max 80 lines. Rotate weekly.

## Active TODOs

```bash
grep -rn "TODO\|FIXME" --include="*.nix" . | grep -v node_modules
```

| Tag | File | Line | Item |
|-----|------|------|------|
| TODO | hosts/alice/packages.nix | 6 | remove vim after neovim configured |
| TODO | hosts/alice/packages.nix | 28 | audit pamixer overlap with pipewire |
| TODO | hosts/alice/packages.nix | 47 | consolidate GTK with home-manager |
| TODO | hosts/alice/packages.nix | 51 | move virt pkgs to services/virt.nix |
| TODO | hosts/alice/security.nix | 5 | add layered controls, fail2ban |
| FIXME | hosts/alice/security.nix | 8 | require sudo password |

## 2026-01-30

**Sprint:** Documentation cleanup, bootcamp env docs

| Time | Items | Status |
|------|-------|--------|
| 10:30 | xonsh-uvox-usage.md | done |
| 10:45 | uv-environment-plan.md | done |
| 11:00 | monorepo-environments.md | done |
| 11:15 | bootcamp push | done |
| 11:30 | nixos docs review | done |
| 11:38 | flake.nix homeModules fix | done |
| 11:40 | git staging (docs, deletions) | done |
| 11:45 | tag TODOs in packages.nix, security.nix | done |

**Completed:** 8 | **Blocked:** 0 | **Research:** 1 (homeModules naming)

---

## Backlog (from README.md)

| # | Task | Est |
|---|------|-----|
| 1 | Add fallback DE (xfce4) | S |
| 2 | Add autorandr config | S |
| 3 | Test uv venv + prompt | M |
| 4 | Document gup alias risks | S |
| 5 | Document webup alias | S |
| 6 | Remove unused command_output() | S |
| 7 | Add LSPs (nixd, pyright) | M |
| 8 | Update Obsidian vault path | S |
| 9 | Test image.nvim | M |
| 10 | Configure keybindings | L |

Est: S=small, M=medium, L=large

---

## Notes

- homeModules is correct (not homeManagerModules) per flake-parts
- uvox delegates to uv - shell integration only
- bootcamp docs: github.com/Monaciello/boot-camp/docs/environment/
