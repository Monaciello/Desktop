# Phase 3: Add Development Layer (Layer 2) Guide

**Objective:** Design Layer 2 for nixvim shortcuts and clipboard workflow (**HIGH PRIORITY**)

**Time estimate:** 2-3 hours

**Addresses:** wip.md line 33 (nvim clipboard gap), HIGH PRIORITY nixvim support

---

## Overview

Layer 2 prioritizes:
1. **System clipboard integration** - yank/paste with system clipboard
2. **LSP shortcuts** - Go to definition, hover docs, code actions
3. **Fuzzy finder** - Telescope file/grep search
4. **Navigation** - Harpoon bookmarks for quick file jumping

Activated by: **Enter held** (or customizable)

---

## Layer 2 Design (Enter-hold)

### In keymapp:
1. Create new layer "LAYER2_DEV"
2. Right-click Layer 0's Enter key
3. Set to "momentary layer LAYER2_DEV"

---

## Key Mappings

### Clipboard Operations (HIGH PRIORITY)
These send Neovim commands for system clipboard integration:

```
Y → Macro: "+y  (system clipboard yank in nvim)
P → Macro: "+p  (system clipboard paste in nvim)
```

**How to create macro in keymapp:**
- Right-click key → "Macro"
- Type: `"+y` (literally the characters: quote, plus, y)
- Click "Add"

**Note:** ✓ Clipboard is configured with `vim.opt.clipboard = "unnamedplus"` in nvim init.lua (resolved)

---

### LSP Shortcuts

```
G → Macro: gd  (go to definition)
K → Macro: K   (hover documentation)
R → Macro: Space+rn (rename, assuming leader=Space)
A → Macro: Space+vca (code actions, vim code action)
```

**Note:** These assume neovim LSP is configured (nixvim migration goal)

---

### Telescope - Fuzzy Finder

```
F → Macro: Space+ff (find files, telescope leader binding)
C → Macro: Space+fg (live grep/find, telescope live grep)
B → Macro: Space+fb (find in buffers)
```

**In nvim (from keybindings.md):**
```lua
<leader>ff - Find files
<leader>fg - Live grep
<leader>fb - Buffers
```

---

### Harpoon - Bookmarks

Harpoon lets you mark files and jump to them quickly (Space+m for menu).

```
1 → Macro: Space+1  (jump to harpoon file 1)
2 → Macro: Space+2  (jump to harpoon file 2)
3 → Macro: Space+3  (jump to harpoon file 3)
4 → Macro: Space+4  (jump to harpoon file 4)
5 → Macro: Space+5  (jump to harpoon file 5)
6 → Macro: Space+6  (jump to harpoon file 6)
7 → Macro: Space+7  (jump to harpoon file 7)
8 → Macro: Space+8  (jump to harpoon file 8)
9 → Macro: Space+9  (jump to harpoon file 9)

M → Macro: Space+m  (harpoon menu)
```

---

## Macro Syntax in keymapp

For simple key presses:
```
gd → Just type: gd
K → Just type: K
```

For Ctrl/Shift/Alt combinations:
```
Space+rn → Type: Space+r+n (keymapp interprets + as separate presses)
Ctrl+O → Type Ctrl+O (keymapp should auto-format)
```

For special keys:
```
Escape → Type: Escape (or esc)
Enter → Type: Enter (or ret)
```

---

## Layout Map

```
Layer 2 (Enter held) - DEV/EDITOR

Left Hand:              Right Hand:
  G→gd                    Y→"+y (yank)
  R→rn (rename)           U→Home
  A→Code Acts             I→PgUp
  (rest unmapped)         O→End
                          P→"+p (paste)

Pinky keys:
  F→telescope find
  C→telescope grep
  B→telescope buffers

Bottom row (1-9):
  1-9→Space+1-9 (harpoon)
  M→Space+m (harpoon menu)
```

---

## Testing Workflow

After flashing Layer 2:

```bash
# In nvim with LSP configured:

# Test clipboard (needs vim.opt.clipboard = "unnamedplus")
# 1. Yank in nvim: Hold Enter, press Y
# 2. Paste in browser: Ctrl+V
# Expected: Last yanked text appears

# Test LSP
# 1. Hover on a function: Hold Enter, press K
# Expected: Hover documentation appears

# Test Telescope
# 1. Open project: Hold Enter, press F
# Expected: File picker appears

# Test Harpoon
# 1. Mark current file: Space+m, select 1
# 2. Jump to file: Hold Enter, press 1
# Expected: Jump to marked file
```

---

## Success Criteria

- [ ] Layer 2 created and momentary-bound to Enter
- [ ] All macro keys mapped correctly in keymapp
- [ ] Firmware flashes without errors
- [ ] Clipboard yank/paste works (Y and P keys)
- [ ] LSP shortcuts work (gd, K, rn, A keys)
- [ ] Telescope shortcuts work (F, C, B keys)
- [ ] Harpoon shortcuts work (1-9, M keys)
- [ ] No conflicts with Layer 0 or Layer 1

---

## Troubleshooting

### Macros not working
- Verify keymapp accepted the macro (check preview)
- Try shorter macro first: Just "g" then "d" separately
- Check nvim keybindings match (Space as leader?)

### Clipboard not working
- Check nvim config has `vim.opt.clipboard = "unnamedplus"`
- Verify xclip is installed: `which xclip`
- Test manually: `echo test | xclip -selection clipboard`

### Layer 2 not activating
- Check Enter key is set to "momentary layer LAYER2_DEV"
- Try momentary layer keycodes instead of direct mapping
- Test with Oryx web configurator

---

## Next Phase

Once Layer 2 works reliably, move to Phase 4: Add window manager layer (i3 + tmux).

**Files:** `home-manager/programs/zsa/layouts/dev.kbd`

**Note:** Save from keymapp as you build. When done, export complete layout as `dev.kbd`.
