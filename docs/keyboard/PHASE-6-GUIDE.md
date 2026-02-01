# Phase 6: Add Automation (Optional) Guide

**Objective:** Setup context-aware layer switching with kontroll

**Time estimate:** 2-3 hours

**Note:** This phase is **OPTIONAL**. Phases 1-5 create a fully functional keyboard without automation.

---

## Overview

Phase 6 adds automatic layer switching:
- **Detect nvim** → Auto-switch to Layer 2 (dev shortcuts)
- **Detect browser** → Auto-switch to Layer 1 (navigation)
- **Detect tmux** → Stay on Layer 3 (window management)

This requires:
1. **kontroll** - ZSA keyboard automation daemon (in hardware.nix)
2. **Detection scripts** - Identify active application
3. **Layer switching** - Hook to change keyboard layer

---

## Prerequisites

Verify kontroll is available:

```bash
# Should be in system packages from Phase 1 (hardware/keyboard.nix)
which kontroll
kontroll --version
```

If missing, add to `hosts/alice/hardware/keyboard.nix`:
```nix
environment.systemPackages = with pkgs; [ kontroll ];
```

Then: `sudo nixos-rebuild switch --flake .#alice`

---

## Architecture

```
i3/window manager
     ↓
   (detect active window)
     ↓
detect-nvim.sh / detect-app.sh
     ↓
switch-layer.sh
     ↓
kontroll / keymapp (change keyboard layer)
```

---

## Step 1: Create Detection Scripts

Create `home-manager/programs/zsa/automation/scripts/detect-nvim.sh`:

```bash
#!/bin/bash
# Detect if neovim is the active window

# Method 1: Check i3 active window class
active_window=$(i3-msg -t get_tree | jq -r 'recurse(.nodes[]?) | select(.focused==true) | .window_properties.class' 2>/dev/null)

if [[ "$active_window" == *"nvim"* ]] || [[ "$active_window" == *"vim"* ]]; then
  echo "nvim"
  exit 0
else
  echo "other"
  exit 1
fi
```

Create `home-manager/programs/zsa/automation/scripts/detect-app.sh`:

```bash
#!/bin/bash
# Detect active application type

active_class=$(i3-msg -t get_tree | jq -r 'recurse(.nodes[]?) | select(.focused==true) | .window_properties.class' 2>/dev/null)

case "$active_class" in
  *nvim*|*vim*)
    echo "nvim"
    ;;
  *tmux*|*kitty*|*terminal*)
    echo "terminal"
    ;;
  *firefox*|*chromium*|*chrome*)
    echo "browser"
    ;;
  *)
    echo "default"
    ;;
esac
```

Create `home-manager/programs/zsa/automation/scripts/switch-layer.sh`:

```bash
#!/bin/bash
# Switch keyboard layer using keymapp CLI or kontroll

layer=$1

if [[ -z "$layer" ]]; then
  echo "Usage: switch-layer.sh <layer_number>"
  exit 1
fi

# Method 1: kontroll (if available)
if command -v kontroll &> /dev/null; then
  kontroll set-layer "$layer"
  exit 0
fi

# Method 2: keymapp CLI (if available)
if command -v keymapp &> /dev/null; then
  # Note: keymapp may not have CLI layer switching
  # This is a fallback; kontroll is preferred
  echo "Using kontroll is recommended"
  exit 1
fi

echo "Error: kontroll or keymapp not found"
exit 1
```

---

## Step 2: Create kontroll Configuration

Create `home-manager/programs/zsa/automation/kontroll.nix`:

```nix
{ config, pkgs, ... }:
{
  # kontroll automation - requires i3 IPC access
  #
  # This module would configure kontroll rules like:
  # - When nvim is active → Layer 2
  # - When terminal → Layer 3
  # - When browser → Layer 1
  #
  # Note: kontroll daemon must be running
  # Add to user systemd services or i3 startup
}
```

---

## Step 3: Setup i3 Integration

Option 1: Launch script on window focus change (via i3 exec)

Add to `home-manager/modules/i3.nix`:

```nix
{
  # i3 automatically detects window changes
  # Could hook detect-app.sh here via exec_always or on_window_focus
}
```

Option 2: Run kontroll daemon in background

Add to i3 startup:

```bash
# In i3 config
exec --no-startup-id kontroll --watch-active-window
```

---

## Step 4: Test Automation

```bash
# Start kontroll in background
kontroll &

# Test detection script
/home/sasha/Projects/nixos/home-manager/programs/zsa/automation/scripts/detect-nvim.sh

# Open nvim
nvim

# Check if layer auto-switched
# (depends on kontroll implementation)

# Test switch-layer.sh
/home/sasha/Projects/nixos/home-manager/programs/zsa/automation/scripts/switch-layer.sh 2
```

---

## Troubleshooting

### kontroll not found
```bash
# Install in hardware config
sudo nixos-rebuild switch --flake .#alice
```

### Detection scripts fail
```bash
# Check i3 is running
i3 --version

# Check jq is installed
which jq

# Test i3-msg directly
i3-msg -t get_tree | jq '.nodes[].nodes[].window_properties.class'
```

### Layer switching doesn't work
- Verify kontroll daemon is running: `ps aux | grep kontroll`
- Check keyboard is connected
- Test manual layer switch in keymapp
- Try alternative: Use keymapp web configurator for conditional logic

---

## Alternative: keymapp Conditional Layers

**Simpler approach without kontroll:**

Many modern keyboards support conditional layer activation:
- Layer 2 (dev) activates when specific app detected
- Layer 3 (window) always available
- Layer 4 (apps) when launcher focused

Check keymapp GUI for "conditional layer" or "leader key" options.

---

## Success Criteria

- [ ] kontroll installed and runnable
- [ ] Detection scripts work (`detect-nvim.sh`, `detect-app.sh`)
- [ ] Layer switching works (`switch-layer.sh 2` changes layer)
- [ ] Integration hooked to i3 (automatic on window switch)
- [ ] nvim windows auto-switch to Layer 2
- [ ] Browser windows auto-switch to Layer 1

---

## Decision: To Phase 6 or Not?

**Skip Phase 6 if:**
- Current keyboard works well without automation
- Manual layer switching is fine
- Complexity not worth the benefit

**Do Phase 6 if:**
- Want seamless app-specific workflows
- Have time for integration testing
- Want to explore kontroll capabilities

---

## Files

```
home-manager/programs/zsa/automation/
├── kontroll.nix
└── scripts/
    ├── detect-app.sh
    ├── detect-nvim.sh
    └── switch-layer.sh
```

---

## Next Phase

Once complete, move to Phase 7: Create final documentation.
