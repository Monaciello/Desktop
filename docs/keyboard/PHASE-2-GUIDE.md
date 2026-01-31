# Phase 2: Create Minimal Base Layer (Layer 0-1) Guide

**Objective:** Design and flash Layer 0 (standard QWERTY) and Layer 1 (Space-hold navigation)

**Time estimate:** 1-2 hours (mostly keymapp interaction)

---

## Step 1: Launch keymapp GUI

```bash
# After nixos-rebuild switch, keymapp should be available
keymapp
```

Or use the Oryx web configurator: https://configure.zsa.io

---

## Step 2: Design Layer 0 (BASE)

### Configuration
- **Name:** BASE
- **Key Layout:** Standard QWERTY
- **Special Keys:**
  - Esc, Tab, Enter, Backspace (standard)
  - Modifiers: Ctrl, Shift, Alt, Super (standard)
  - **Space bar → hold activates Layer 1**

### Details
- Nothing special on Layer 0
- Standard typing experience
- Space bar acts as toggle to Layer 1 when held

**Save as:** `layers/base.kbd` (partial save, you'll add layers below)

---

## Step 3: Design Layer 1 (NAVIGATION - Hold Space)

### Configuration
- **Name:** LAYER1_NAVIGATION
- **Activate:** When Space is held
- **Purpose:** Vim-style navigation + function keys (supports nixvim migration)

### Key Mappings

**Right Hand - Arrows (vim-style):**
```
Layer 1 (Space held):
  H → Left Arrow
  J → Down Arrow
  K → Up Arrow
  L → Right Arrow
```

**Navigation Keys:**
```
  I → Page Up
  K → Page Down
  U → Home
  O → End
```

**Function Keys - Top Row:**
```
  1 → F1
  2 → F2
  3 → F3
  4 → F4
  5 → F5
  6 → F6
  7 → F7
  8 → F8
  9 → F9
  0 → F10
  - → F11
  = → F12
```

**Left Hand - Leader Prefix (for Phase 3+):**
```
  Space (thumb) → Space key passthrough
  (Will add Space+modifier macros in Phase 3)
```

### In keymapp:
1. Create new layer "LAYER1_NAVIGATION"
2. Right-click Layer 0's Space bar
3. Set to "momentary layer LAYER1_NAVIGATION"
4. Map each key as above
5. Leave unmapped keys empty (will fall through to Layer 0)

---

## Step 4: Test Layer 1 in Neovim

```bash
# After flashing (Step 5), test in nvim:
nvim

# Hold Space and test:
# - HJKL should move cursor (arrow keys)
# - I/K should page up/down
# - U/O should go to start/end of line
```

Expected behavior:
- Cursor moves with space+hjkl
- Function keys available for LSP hover, goto, etc.

---

## Step 5: Export and Flash

### In keymapp:
1. **Export:** Menu → Export → Save as `.keymap` or `.hex`
2. **Or use Oryx:** Download `.hex` file

### Flash to keyboard:
```bash
# Put keyboard in bootloader mode (hold ESC while plugging in)
wally-cli /path/to/firmware.hex

# Alternative: use keymapp's built-in flash button
```

### Verify flash:
- Keyboard should reboot
- Test Space+HJKL navigation in nvim
- All other keys should still work normally

---

## Troubleshooting

### keymapp won't start
```bash
# Check if installed
which keymapp

# Try with explicit path
/run/current-system/sw/bin/keymapp
```

### Keyboard won't flash
- Put keyboard in bootloader mode: Hold ESC while connecting USB
- Try: `wally-cli --help` for CLI usage
- Try Oryx web configurator instead: https://configure.zsa.io

### Layer 1 keys not working after flash
- Verify Layer 1 keys are mapped to arrow keys (not left/right/up/down)
- Check Space bar is set to "momentary layer" (not "toggle")
- Re-flash firmware

---

## Success Criteria

- [ ] keymapp launches without errors
- [ ] Layer 0 and Layer 1 visible in keymapp
- [ ] Space bar momentary-activates Layer 1
- [ ] Layer 1 HJKL mapped to arrow keys
- [ ] Firmware flashes successfully
- [ ] Space+HJKL moves cursor in nvim
- [ ] Regular typing still works on Layer 0

---

## Next Phase

Once Layer 0-1 work, move to Phase 3: Add development layer with nixvim shortcuts and clipboard workflow.

**Files:** `home-manager/programs/zsa/layouts/base.kbd`

**Save location:** After exporting from keymapp, save to `/home/sasha/Projects/nixos/home-manager/programs/zsa/layouts/base.kbd`
