# WIP - Sprint Tracker

Daily sprint log. Max 80 lines. Rotate weekly.

## Active TODOs

**All items completed as of 2026-02-04:**

| Status | Item | Resolution |
|--------|------|------------|
| ✓ DONE | Remove vim (packages.nix:6) | Removed - neovim fully configured |
| ✓ DONE | Audit pamixer (packages.nix:28) | Removed - unused, pactl handles volume |
| ✓ DONE | Consolidate GTK (packages.nix:47) | Removed - managed by home-manager/modules/gtk.nix |
| ✓ DONE | Move virt packages (packages.nix:51) | Moved to hosts/alice/services/virt.nix |
| ✓ DONE | Add fail2ban (security.nix:5) | Configured with incremental banning |
| ✓ DONE | Require sudo password (security.nix:8) | Already correct - no change needed |
| ✓ DONE | Neovim LSPs (Phase 1) | nixd/pyright via Nix extraPackages, lspconfig in init.lua |
| ✓ DONE | Obsidian vault path | Configured ~/Files/Obsidian in obsidian-nvim |
| ✓ DONE | xonshrc documentation | Enhanced gup/webup alias warnings and usage docs |

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

## Gaps (Resolved)

| Item | Status | Resolution |
|------|--------|------------|
| nvim clipboard | ✓ FIXED | Added vim.opt.clipboard="unnamedplus" to init.lua |
| impure nvim | ✓ IMPROVED | nixd + pyright LSPs via Nix; removed Mason |
| xonsh security | ✓ FIXED | Rewrote gup, set_wallpaper, set_display; added untar function |
| fzf unused | DEFERRED | Telescope covers fuzzy finding needs in nvim |

---

## Nixvim Decision (RESOLVED)

**Decision:** Keep vanilla init.lua approach with declarative LSP management via Nix

**Rationale:**
- Removed lazy.nvim (dynamic plugin management conflicts with Nix declarativity)
- Removed Mason (automatic LSP downloads) - now using nixd, pyright via Nix
- Vanilla Lua + home-manager declarative plugins is reproducible and maintainable
- Declarative LSP binaries in neovim.nix provides full reproducibility
- Simpler init.lua (230 lines) without plugin bootstrap code
- No need for full nixvim typing/configuration complexity

**Changes Implemented:**
- ✓ Removed lazy.nvim, using home-manager declarative plugin management
- ✓ Added nixd, pyright to extraPackages in neovim.nix
- ✓ Configured LSPs via lspconfig in clean init.lua
- ✓ Added clipboard support (vim.opt.clipboard="unnamedplus")
- ✓ Configured obsidian-nvim vault path (~/Files/Obsidian)
- ✓ All LSP keybindings documented in docs/keybindings.md
