# Phase 4: Add Window Manager Layer (Layer 3) Guide

**Objective:** Design Layer 3 for i3 workspace/window control + tmux

**Time estimate:** 1-2 hours

**Addresses:** MEDIUM PRIORITY i3 integration, tmux workflow (from wip.md)

---

## Overview

Layer 3 provides one-handed window management:
- Workspace switching (Alt+1-0)
- Window navigation (Alt+HJKL)
- Window movement (Alt+Shift+HJKL)
- Fullscreen/resize/gaps modes
- Tmux prefix for pane navigation

Activated by: **Hyper (Cmd/Win) held** or customize

---

## Keybindings Reference

From `docs/keybindings.md` - i3 keybindings:

```
Mod (Alt) + 1-0         → Switch workspace
Mod + h/j/k/l           → Focus window (left/down/up/right)
Mod + Shift + h/j/k/l   → Move window
Mod + f                 → Fullscreen toggle
Mod + r                 → Resize mode
Mod + g                 → Gaps (if configured)
```

From `docs/keybindings.md` - tmux keybindings:

```
Prefix: Ctrl+Space
Prefix + h/j/k/l        → Navigate panes (vim-style)
Prefix + n/p            → Next/previous window
Prefix + c              → New window
```

---

## Layer 3 Design (Hyper-hold)

### In keymapp:
1. Create new layer "LAYER3_WINDOW_MGR"
2. Identify Hyper thumb key (or use custom modifier)
3. Set to "momentary layer LAYER3_WINDOW_MGR"

---

## Key Mappings

### Workspace Switching (1-10)

```
1 → Macro: Alt+1    (workspace 1)
2 → Macro: Alt+2    (workspace 2)
3 → Macro: Alt+3    (workspace 3)
4 → Macro: Alt+4    (workspace 4)
5 → Macro: Alt+5    (workspace 5)
6 → Macro: Alt+6    (workspace 6)
7 → Macro: Alt+7    (workspace 7)
8 → Macro: Alt+8    (workspace 8)
9 → Macro: Alt+9    (workspace 9)
0 → Macro: Alt+0    (workspace 10)
```

### Window Navigation & Movement (HJKL)

```
H → Macro: Alt+h    (focus left window)
J → Macro: Alt+j    (focus down window)
K → Macro: Alt+k    (focus up window)
L → Macro: Alt+l    (focus right window)

Shift+H → Macro: Alt+Shift+h (move window left)
Shift+J → Macro: Alt+Shift+j (move window down)
Shift+K → Macro: Alt+Shift+k (move window up)
Shift+L → Macro: Alt+Shift+l (move window right)
```

### i3 Modes

```
F → Macro: Alt+f    (fullscreen toggle)
R → Macro: Alt+r    (resize mode)
G → Macro: Alt+g    (gaps mode, if configured)
```

### Tmux Integration (Left Thumb)

```
Left Thumb → Macro: Ctrl+Space  (tmux prefix)

Then in tmux, chain commands:
Prefix + H/J/K/L → Navigate panes
Prefix + n/p     → Next/previous window
Prefix + c       → New window
```

**Alternative:** Create a dedicated tmux layer for faster access

---

## Layout Map

```
Layer 3 (Hyper-hold) - WINDOW MANAGER

Left Hand:          Workspace (1-5):    Right Hand:
  (keys 1-5)          1 2 3 4 5           H→Alt+h (left)
  (keys 6-0)          6 7 8 9 0           J→Alt+j (down)
  (modes)           Shift+H/J/K/L         K→Alt+k (up)
                    Alt+Shift             L→Alt+l (right)

Bottom row:
  F→Alt+f (fullscreen)
  R→Alt+r (resize)
  G→Alt+g (gaps)
  Thumb→Ctrl+Space (tmux prefix)
```

---

## Testing Workflow

After flashing Layer 3:

```bash
# Test workspace switching
Hold Hyper, press 1  → Should switch to workspace 1
Hold Hyper, press 2  → Should switch to workspace 2

# Test window navigation
Hold Hyper, press H  → Focus left window
Hold Hyper, Shift+H  → Move window left

# Test tmux
Hold Hyper, press Thumb → Opens tmux command mode
Then: n (next window), p (previous), c (new)

# Test i3 modes
Hold Hyper, press F  → Fullscreen current window
Hold Hyper, press R  → Enter resize mode
```

---

## i3 Configuration Check

Verify keybindings in `home-manager/modules/i3.nix`:

```nix
# Should have:
bindsym $mod+1 workspace number 1
bindsym $mod+h focus left
bindsym $mod+Shift+h move left
bindsym $mod+f fullscreen toggle
```

From current config (keybindings.md):
- Mod key is Alt ✓
- HJKL window nav ✓
- Workspace 1-10 ✓
- Fullscreen ✓

---

## Success Criteria

- [ ] Layer 3 created and momentary-bound to Hyper key
- [ ] Workspace switching works (Alt+1-0)
- [ ] Window focus works (Alt+HJKL)
- [ ] Window movement works (Alt+Shift+HJKL)
- [ ] Fullscreen/resize modes work (Alt+F/R)
- [ ] Tmux prefix accessible (Ctrl+Space)
- [ ] No conflicts with Layer 0-2

---

## Troubleshooting

### Workspace won't switch
- Verify i3 is running: `i3 --version`
- Check i3 config has keybindings
- Test manually: `Alt+1` should switch

### Window nav macros not working
- Verify Alt key sends correctly
- Test: `xdotool key alt+h` (should focus left)
- Check i3 uses "left/down/up/right" or h/j/k/l

### Tmux prefix not working
- Verify tmux prefix is Ctrl+Space: `tmux list-keys | grep prefix`
- Test manually: `Ctrl+Space n` should open new window

---

## Next Phase

Once Layer 3 works, move to Phase 5: Add app launcher layer (media controls).

**Files:** `home-manager/programs/zsa/layouts/complete.kbd` (add Layer 3)
