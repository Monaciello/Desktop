# WIP - Sprint Tracker

Daily sprint log. Max 80 lines. Rotate weekly.

## Active TODOs

| Tag | File | Item |
|-----|------|------|
| TODO | packages.nix:6 | remove vim after neovim configured |
| TODO | packages.nix:28 | audit pamixer overlap |
| TODO | packages.nix:47 | consolidate GTK |
| TODO | packages.nix:51 | move virt pkgs |
| TODO | security.nix:5 | add fail2ban |
| FIXME | security.nix:8 | require sudo password |

## 2026-01-30

| Task | Duration | Status |
|------|----------|--------|
| docs consolidation, options-audit, nixvim review | 8h | done |

---

## Integration Patterns

**Terminal**: kitty→tmux→nvim via vim-tmux-navigator (C-h/j/k/l)
```lua
-- init.lua:534-538, tmux.nix:31-35
keymap("n", "<C-h>", ":TmuxNavigateLeft<CR>")
```

**Clipboard**: tmux `y` → xclip (tmux.nix:55), xonsh `xc` alias (xonshrc:146)
- **GAP**: nvim missing `vim.opt.clipboard = "unnamedplus"`

**Launcher**: i3 → Alt+s (rofi/apps), Alt+c (rofimoji)

**Dev**: nvim telescope (C-o find files), harpoon (leader+m menu), obsidian (Win+o, A-i template)

---

## Gaps

| Item | Impact | Fix |
|------|--------|-----|
| nvim clipboard | Med | vim.opt.clipboard="unnamedplus" |
| fzf unused | Med | Add xonsh/nvim keybinds |
| impure nvim | High | Migrate to nixvim (priority #1) |

---

## Nixvim Decision (HIGH IMPACT)

Migrate init.lua (624 lines, impure lazy.nvim+Mason) → nixvim (typed, reproducible)?

**Options:**
- A) Import as flake input → overlay
- B) Merge into home-manager/modules/neovim.nix ← **Recommended**
- C) Keep separate, symlink output

**Priority Matrix:**
- nixvim LSP + remove Mason: High impact, Med effort
- Typed plugin configs: Med impact, High effort
- sudo.wheelNeedsPassword: High impact, Low effort ← Do first
- fail2ban: Med impact, Low effort

**Next:** Decide A/B/C, then migrate LSP config.
