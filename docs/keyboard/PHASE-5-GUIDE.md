# Phase 5: Add App Launcher Layer (Layer 4) Guide

**Objective:** Design Layer 4 for app launchers and media controls

**Time estimate:** 1 hour

**Addresses:** MEDIUM PRIORITY system controls, convenience shortcuts

---

## Overview

Layer 4 provides quick access to:
- App launchers (Discord, Firefox, Obsidian, etc.)
- System utilities (rofi, lf file manager, Flameshot)
- Media controls (volume, brightness, mute)

Activated by: **Meh (Alt+Ctrl) held** or customize

---

## Keybindings Reference

From `docs/keybindings.md` - i3 Super key shortcuts:

```
Super+v → Firefox
Super+o → Obsidian
Super+l → lf (file manager)
```

From `docs/keybindings.md` - i3 Alt key shortcuts:

```
Alt+s  → Rofi (launcher)
```

---

## Layer 4 Design (Meh-hold)

### In keymapp:
1. Create new layer "LAYER4_APP_LAUNCHER"
2. Identify Meh thumb key (or use custom modifier)
3. Set to "momentary layer LAYER4_APP_LAUNCHER"

---

## Key Mappings

### App Launchers

```
S → Macro: Alt+s      (rofi application launcher)
D → Macro: Super+d    (Discord)
F → Macro: Super+f    (Flameshot screenshot)
L → Macro: Super+l    (lf file manager)
O → Macro: Super+o    (Obsidian notes)
V → Macro: Super+v    (Firefox browser)
```

**Super key:** Alt+Super in macro form, or configure Super directly

---

### Media Controls

Map to XF86 multimedia keys (most systems recognize these):

```
Volume Up    → XF86AudioRaiseVolume  (or: Macro: Super+AudioRaiseVolume)
Volume Down  → XF86AudioLowerVolume  (or: Macro: Super+AudioLowerVolume)
Mute         → XF86AudioMute         (or: Macro: Super+AudioMute)

Brightness Up   → XF86MonBrightnessUp    (or: Macro: Super+Up)
Brightness Down → XF86MonBrightnessDown  (or: Macro: Super+Down)
```

**In keymapp:**
- Look for "Media" category in key selector
- Or search for "XF86Audio" / "XF86Brightness"

**Fallback macros** (if XF86 keys unavailable):
```
Volume Up    → Macro: Super+Up
Volume Down  → Macro: Super+Down
Mute         → Macro: Super+m
```

---

## Layout Map

```
Layer 4 (Meh-hold) - APP LAUNCHER

Top Row (Apps):          Media Keys:
  S→rofi                   (top right)
  D→Discord                Vol↑ Vol↓ Mute
  F→Flameshot              Bright↑ Bright↓
  L→lf
  O→Obsidian
  V→Firefox

Flexible mapping:
  Can also use number keys for app shortcuts
  Can also map to Super+key for i3 bindings
```

---

## Testing Workflow

After flashing Layer 4:

```bash
# Test app launchers
Hold Meh, press S     → Rofi should open
Hold Meh, press V     → Firefox should open
Hold Meh, press O     → Obsidian should open

# Test media controls
Hold Meh, press VolUp → Volume should increase
Hold Meh, press VolDn → Volume should decrease
Hold Meh, press Mute  → Audio should mute/unmute

# Test brightness
Hold Meh, press BriUp → Brightness should increase
Hold Meh, press BriDn → Brightness should decrease
```

---

## i3 Configuration Check

Verify keybindings in `home-manager/modules/i3.nix`:

Current bindings (from keybindings.md):
```
Alt+s  → rofi         ✓
Super+v → Firefox     ✓
Super+o → Obsidian    ✓
Super+l → lf          ✓
```

These should work with Layer 4 macros.

---

## Media Keys System Check

Verify media keys work:

```bash
# Test volume
amixer set Master 5%+  # Raise by 5%
amixer set Master 5%-  # Lower by 5%
amixer set Master toggle  # Mute/unmute

# Test brightness (using brightnessctl from packages.nix)
brightnessctl set 10%+
brightnessctl set 10%-
```

If XF86 keys don't work, keymapp will send macros instead.

---

## Success Criteria

- [ ] Layer 4 created and momentary-bound to Meh key
- [ ] App launcher keys work (S, D, F, L, O, V)
- [ ] Media control keys recognized by system
- [ ] Volume control functional
- [ ] Brightness control functional
- [ ] Mute toggle works
- [ ] No conflicts with Layer 0-3

---

## Troubleshooting

### App launchers not opening
- Verify i3 keybindings are set: `grep -A5 "bindsym Super" ~/.config/i3/config`
- Test manually: `Super+v` should open Firefox
- Check if app is installed: `which firefox`

### Media keys not working
- Check if XF86 keys are recognized: `xev` (press volume key)
- Verify pulseaudio/pipewire is running: `pactl info`
- Test manually: `amixer set Master 5%+`

### Volume control not responding
- Check if pamixer or similar is needed
- Try: `pulseaudio-ctl up` (if installed)
- Or: `pactl set-sink-volume @DEFAULT_SINK@ +5%`

### Brightness not responding
- Verify brightnessctl installed: `which brightnessctl` ✓ (in packages.nix)
- Test manually: `brightnessctl set 50%`
- Check if backlight device exists: `ls /sys/class/backlight/`

---

## Next Phase

Once Layer 4 works, you have a complete, functional keyboard layout!

**Optional Phase 6:** Add context-aware automation with kontroll (automatic layer switching).

**Files:** `home-manager/programs/zsa/layouts/complete.kbd` (add Layer 4)
