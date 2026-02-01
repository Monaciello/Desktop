# ZSA Keyboard Layer Reference

Complete documentation for ZSA keyboard configuration in this NixOS setup.

---

## Quick Start

1. **Phase 1 (DONE):** Hardware setup and tools installed
2. **Phase 2:** Design Layer 0-1 (navigation) - Start here with keymapp
3. **Phase 3:** Design Layer 2 (dev/editor) - HIGH PRIORITY
4. **Phase 4:** Design Layer 3 (window manager) - MEDIUM
5. **Phase 5:** Design Layer 4 (app launcher) - MEDIUM
6. **Phase 6 (Optional):** Setup automation with kontroll
7. **Phase 7 (This file):** Documentation

**See detailed guides:** `PHASE-2-GUIDE.md` through `PHASE-6-GUIDE.md`

---

## Hardware Setup

**Device:** ZSA Ergodox EZ (or similar keyboard)

**System Integration:**
- Firmware flashing: `wally-cli` (CLI tool)
- Configuration GUI: `keymapp` (system-level GUI)
- Automation (optional): `kontroll` (automatic layer switching)

**Firmware Format:** `.hex` or `.keymap`

**Configuration Files:**
- Keyboard layouts stored in: `home-manager/programs/zsa/layouts/`
- Automation scripts: `home-manager/programs/zsa/automation/scripts/`

---

## Layer Overview

### Layer 0: BASE
Standard QWERTY typing. Nothing modified.

- Space bar → **Hold to activate Layer 1**
- Enter key → **Hold to activate Layer 2**
- Hyper → **Hold to activate Layer 3**
- Meh → **Hold to activate Layer 4**

### Layer 1: NAVIGATION (Hold Space)
Vim-style movement for cross-program navigation.

**Right Hand (Arrow Keys):**
```
H → Left
J → Down
K → Up
L → Right
```

**Navigation:**
```
I → Page Up
K → Page Down
U → Home
O → End
```

**Function Keys (1-0, -, =):**
```
1-0 → F1-F10
- → F11
= → F12
```

**Use Case:** Navigating in nvim, browsers, terminals without reaching the arrow key cluster.

---

### Layer 2: DEV/EDITOR (Hold Enter) - **HIGH PRIORITY**
Nixvim-optimized editing shortcuts and clipboard integration.

#### Clipboard (System Integration)
```
Y → Yank to system clipboard   (" +y macro)
P → Paste from system clipboard (" +p macro)
```

**Requires:** `vim.opt.clipboard = "unnamedplus"` in nvim config

#### LSP (Language Server Protocol)
```
G → Go to definition (gd)
K → Hover documentation (K)
R → Rename variable (Space+rn)
A → Code actions (Space+vca)
```

#### Fuzzy Finder (Telescope)
```
F → Find files (Space+ff)
C → Live grep (Space+fg)
B → Search buffers (Space+fb)
```

#### Navigation Bookmarks (Harpoon)
```
1-9 → Jump to bookmarked file 1-9 (Space+1 through Space+9)
M → Harpoon menu (Space+m)
```

**Use Case:** Fast editing with system clipboard, LSP navigation, fuzzy finding.

---

### Layer 3: WINDOW MANAGER (Hold Hyper)
One-handed i3 window management and tmux integration.

#### Workspace Switching
```
1-0 → Switch to workspace 1-10 (Alt+1 through Alt+0)
```

#### Window Navigation & Moving
```
H → Focus left window (Alt+h)
J → Focus down window (Alt+j)
K → Focus up window (Alt+k)
L → Focus right window (Alt+l)

Shift+H → Move window left (Alt+Shift+h)
Shift+J → Move window down (Alt+Shift+j)
Shift+K → Move window up (Alt+Shift+k)
Shift+L → Move window right (Alt+Shift+l)
```

#### i3 Modes
```
F → Fullscreen toggle (Alt+f)
R → Resize mode (Alt+r)
G → Gaps adjustment (Alt+g)
```

#### Tmux Prefix
```
Left Thumb → Tmux prefix (Ctrl+Space)

Then:
- n → Next window
- p → Previous window
- c → New window
- h/j/k/l → Navigate panes (tmux keybinds)
```

**Use Case:** One-handed workspace switching, window management, multiplexer control.

---

### Layer 4: APP LAUNCHER (Hold Meh)
Quick app launching and media controls.

#### Application Shortcuts
```
S → Rofi launcher (Alt+s)
D → Discord (Super+d)
F → Flameshot screenshot (Super+f)
L → lf file manager (Super+l)
O → Obsidian notes (Super+o)
V → Firefox browser (Super+v)
```

#### Media Controls
```
Volume Up   → XF86AudioRaiseVolume
Volume Down → XF86AudioLowerVolume
Mute        → XF86AudioMute

Brightness Up   → XF86MonBrightnessUp
Brightness Down → XF86MonBrightnessDown
```

**Use Case:** Launch apps and control media without leaving keyboard.

---

### Layer 5: INTEGRATION (Planned)
Context-aware automation (requires Phase 6 setup).

**Ideas:**
- Auto-switch to Layer 2 when nvim focused
- Auto-switch to Layer 1 when browsing
- fzf integration with keyboard trigger
- Custom macros for common workflows

---

## Priority Alignment

| Layer | Priority | Status | TODOs Addressed |
|-------|----------|--------|-----------------|
| 0-1 | Foundation | Phase 2 (User) | Navigation for nixvim |
| 2 | **HIGH** | Phase 3 (User) | Clipboard gap (wip.md:33), nixvim support |
| 3 | **MEDIUM** | Phase 4 (User) | i3 integration, tmux workflow |
| 4 | **MEDIUM** | Phase 5 (User) | System controls, app launchers |
| 5 | LOW | Phase 6 (Optional) | fzf integration, cross-program gaps |

---

## Key Features

### Muscle Memory Preservation
- Alt for i3 (already used in system)
- Space as leader in nvim (already used)
- Ctrl+Space for tmux (already used)
- HJKL for vim-style navigation (already muscle memory)

### Progressive Implementation
- Phases can stop at any point with working keyboard
- Each phase builds on previous layers
- Can skip Phase 6 (automation) entirely

### Integration Points

**Terminal Stack:**
```
kitty → tmux → nvim (via vim-tmux-navigator)
        ↓
  Layer 3: Tmux prefix (Ctrl+Space)
  Layer 1: Navigation in all three
```

**Clipboard Workflow:**
```
nvim (yank with Layer 2: Y)
  ↓ (goes to system clipboard)
browser (paste with Ctrl+V)
```

**i3 Integration:**
```
Layer 3: Alt+1-0 (workspace switch)
         Alt+hjkl (window nav)
         Alt+r (resize)
```

---

## Troubleshooting Quick Guide

### Layer not activating
- Check Layer 0 keys are set to "momentary" for their layers
- Verify holding the trigger key (Space, Enter, Hyper, Meh)
- Re-flash firmware

### Macros not working
- Verify keymapp accepted the macro
- Check nvim keybindings match expectations
- Test with `xdotool` CLI: `xdotool key Super+v` (should open Firefox)

### Keyboard won't flash
- Put keyboard in bootloader: Hold ESC while connecting
- Try: `wally-cli --help` for CLI usage
- Use Oryx web configurator: https://configure.zsa.io

### System clipboard not working
- Verify `xclip` installed: `which xclip`
- Add to nvim: `vim.opt.clipboard = "unnamedplus"`
- Test: `echo test | xclip -selection clipboard` && `xclip -selection clipboard -o`

---

## Design Philosophy

**Why This Layout?**

1. **High-Impact First:** Clipboard + LSP (Layer 2) before extras
2. **Muscle Memory:** Reuses Alt/Space/Ctrl patterns already learned
3. **Progressive:** Each phase adds value, can stop anywhere
4. **Reversible:** Can disable layers without breaking base typing
5. **Maintainable:** Kbd files in version control, documented

---

## Files & Locations

**Configuration:**
- Keyboard hardware: `hosts/alice/hardware/keyboard.nix`
- System packages: `hosts/alice/packages.nix`
- Orchestration: `home-manager/programs/zsa/default.nix`

**Layouts (Created via keymapp GUI):**
- `home-manager/programs/zsa/layouts/base.kbd` (Layer 0-1)
- `home-manager/programs/zsa/layouts/dev.kbd` (Layer 0-2)
- `home-manager/programs/zsa/layouts/complete.kbd` (Layer 0-4)

**Automation (Optional Phase 6):**
- Scripts: `home-manager/programs/zsa/automation/scripts/`
- Config: `home-manager/programs/zsa/automation/kontroll.nix`

**Documentation:**
- This file: `docs/keyboard/layer-reference.md`
- Phase guides: `docs/keyboard/PHASE-2-GUIDE.md` through `PHASE-6-GUIDE.md`

---

## Next Steps

1. **Start Phase 2:** Open keymapp, design Layer 0-1
   - Launch: `keymapp`
   - Follow: `PHASE-2-GUIDE.md`

2. **Test Layer 1:** Flash firmware, test in nvim
   - Flash: `wally-cli /path/to/base.kbd`
   - Test: `nvim`, hold Space, press hjkl

3. **Continue Phases 3-5:** Add dev, window manager, app launcher layers
   - Each phase builds on the previous
   - Can stop at any phase with functional keyboard

4. **Optional Phase 6:** Setup automation with kontroll
   - Auto-switch layers based on active app
   - See: `PHASE-6-GUIDE.md`

---

## Resources

- **ZSA Oryx:** https://configure.zsa.io (web configurator)
- **keymapp:** System GUI for keyboard configuration
- **wally-cli:** Firmware flasher for ZSA keyboards
- **kontroll:** Keyboard automation daemon (optional)

---

## Keyboard Layers Cheat Sheet

```
LAYER 0 (BASE)
Standard QWERTY + modifiers

LAYER 1 (NAVIGATION - Hold Space)
HJKL→Arrows, F1-F12, Home/End/PgUp/PgDn

LAYER 2 (DEV/EDITOR - Hold Enter) ⭐ HIGH PRIORITY
Y/P→Clipboard, LSP (G/K/R/A), Telescope (F/C/B), Harpoon (1-9/M)

LAYER 3 (WINDOW MANAGER - Hold Hyper)
1-0→Workspaces, HJKL→Focus, Shift+HJKL→Move, F/R/G→Modes, Thumb→Tmux

LAYER 4 (APP LAUNCHER - Hold Meh)
S/D/F/L/O/V→Apps, Media controls (Vol/Brightness/Mute)

LAYER 5 (INTEGRATION - Optional kontroll)
Context-aware automation, app-specific workflows
```

---

## Success!

You now have:
- ✓ ZSA keyboard hardware support
- ✓ keymapp and wally-cli tools installed
- ✓ Complete layer reference and guides
- ✓ Progressive implementation path
- ✓ Troubleshooting resources

**Ready to start Phase 2:** `PHASE-2-GUIDE.md`
