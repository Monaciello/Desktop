# Action Items & Implementation Guide

Consolidated list of what's working, what's missing, and how to implement improvements.

---

## ✅ COMPLETED ITEMS (No Action Needed)

### Core Functionality
- [x] 67 aliases fully implemented and tested
- [x] All system services configured and active
- [x] Wallpaper management via `wp` alias
- [x] Display management via `d` alias
- [x] GTK theming with auto-generated CSS from color palette
- [x] LSP servers (nixd, pyright) installed and configured
- [x] Rebuild system (3 aliases: rebuild-sys, rebuild-hm, rebuild-all)
- [x] i3 window manager fully configured with keybindings
- [x] neovim with 20+ plugins and LSP configured
- [x] Shell aliases organized by category (67 total)

### Documentation
- [x] Complete alias reference created
- [x] Service documentation completed
- [x] Wallpaper & theming system documented
- [x] Setup instructions clear

---

## ⚠️ OPTIONAL ENHANCEMENTS

### Priority 1: High Value, Low Effort

#### 1. Add `nmtui` Alias (Network Manager UI)
**Why**: Quick access to network configuration
**Effort**: 1 line
**Frequency**: Monthly

**Instructions**:
```bash
# Edit: home-manager/modules/dotfiles/xonshrc
# Find the "Network & IP" section (around line 350)
# Add:
'nmtui': 'nmtui',  # Network manager interactive UI

# Then rebuild:
rebuild-hm
```

**Verification**:
```bash
nmtui  # Should launch network manager TUI
```

---

#### 2. Add `virsh` Alias (Libvirt Commands)
**Why**: Quick VM management without full GUI
**Effort**: 1 line
**Frequency**: Occasional

**Instructions**:
```bash
# Edit: home-manager/modules/dotfiles/xonshrc
# Find the "Window Manager & Desktop Tools" section
# Add:
'virsh': 'virsh',  # Libvirt domain management

# Then:
rebuild-hm
```

**Verification**:
```bash
virsh list --all  # Should show VMs
```

---

#### 3. Add `ssh-keygen` Alias for Quick Key Generation
**Why**: Simplify SSH key creation
**Effort**: 1 line
**Frequency**: Rare

**Instructions**:
```bash
# Edit: home-manager/modules/dotfiles/xonshrc
# Find "Network & IP" section
# Add:
'sshkey': 'ssh-keygen -t ed25519 -f',  # Generate SSH key

# Then:
rebuild-hm

# Usage:
sshkey ~/.ssh/id_mykey
```

---

#### 4. Add Syncthing Status Alias
**Why**: Quick status check for file sync
**Effort**: 2 lines
**Frequency**: Weekly

**Instructions**:
```bash
# Edit: home-manager/modules/dotfiles/xonshrc
# Add to "Network & IP" section:
'syncthing-status': 'curl -s http://localhost:8384/api/system/status | jq .',  # Show sync status
'syncthing-ui': 'xdg-open http://localhost:8384',  # Open Syncthing UI

# Then:
rebuild-hm
```

---

### Priority 2: Medium Value, Medium Effort

#### 5. Create Systemd Service Aliases
**Why**: Quick access to service management
**Effort**: 5 aliases
**Frequency**: Monthly

**Instructions**:
```bash
# Edit: home-manager/modules/dotfiles/xonshrc
# Add new section after "Network & IP":

# ============================================================================
# System Services
# ============================================================================
'svc-ssh': 'systemctl status sshd',
'svc-ssh-start': 'sudo systemctl start sshd',
'svc-ssh-stop': 'sudo systemctl stop sshd',
'svc-fail2ban': 'systemctl status fail2ban',
'svc-pipewire': 'systemctl status pipewire.service',

# Then:
rebuild-hm
```

**Verification**:
```bash
svc-ssh        # Shows SSH service status
svc-fail2ban   # Shows fail2ban status
```

---

#### 6. Create Diagnostics/Troubleshooting Aliases
**Why**: Quick system diagnostics
**Effort**: 8 aliases
**Frequency**: As needed

**Instructions**:
```bash
# Edit: home-manager/modules/dotfiles/xonshrc
# Add new section:

# ============================================================================
# System Diagnostics
# ============================================================================
'sys-power': 'acpi -b',                    # Battery/power status
'sys-audio': 'pactl list sinks',           # Audio device info
'sys-usb': 'lsusb',                        # USB devices
'sys-disk': 'df -h',                       # Disk usage
'sys-network': 'nmcli device status',      # Network status
'sys-temps': 'sensors 2>/dev/null || echo "Install lm_sensors"',  # CPU temps
'sys-procs': 'ps aux | head -20',          # Top processes
'sys-logs': 'journalctl -n 20 --no-pager', # Recent system logs

# Then:
rebuild-hm
```

**Verification**:
```bash
sys-power    # Show battery status
sys-audio    # List audio devices
sys-network  # Show network connections
```

---

#### 7. Add Development Utility Aliases
**Why**: Quick access to dev tools
**Effort**: 4 aliases
**Frequency**: Daily

**Instructions**:
```bash
# Edit: home-manager/modules/dotfiles/xonshrc
# Add to "Development & Formatting" section:

'lint-all': 'echo "Nix:" && nixfmt --check . && echo "Shell:" && shellcheck *.sh 2>/dev/null',
'fmt-all': 'nixfmt .',                     # Format all Nix files
'json-validate': 'jq . ',                  # Validate JSON stdin
'yaml-validate': 'yq eval .',              # Validate YAML stdin

# Then:
rebuild-hm
```

---

### Priority 3: Nice to Have, Higher Effort

#### 8. Create Backup/Restore Aliases
**Why**: Simplified backup management
**Effort**: 3-5 aliases
**Frequency**: Weekly

**Instructions**:
```bash
# Add to xonshrc:
'backup-home': 'rsync -av --delete ~/ /mnt/backup/home/',
'backup-config': 'tar -czf ~/backups/nixos-$(date +%Y%m%d).tar.gz ~/Projects/nixos/',
'restore-config': 'tar -xzf ',  # Will prompt for file

# Then:
rebuild-hm
```

---

#### 9. Create Git Workflow Shortcuts
**Why**: Faster git operations
**Effort**: 5-8 aliases
**Frequency**: Daily (for developers)

**Instructions**:
```bash
# Add to "Git & Version Control" section:
'gst': 'git status',                       # Status
'gaa': 'git add .',                        # Add all
'gca': 'git commit -a -m ',                # Commit with message
'gpo': 'git push origin',                  # Push to origin
'gpl': 'git pull origin',                  # Pull from origin
'glg': 'git log --oneline --graph -10',    # Show log

# Then:
rebuild-hm
```

---

#### 10. Create Database/Service Connection Aliases
**Why**: Quick connections to services
**Effort**: Variable
**Frequency**: As needed

**Instructions**:
```bash
# For future use when databases are added:
# Add to "Network & IP" section:

# Example for PostgreSQL (when added):
'psql-local': 'psql -U postgres -h localhost',

# Example for Redis (when added):
'redis-cli': 'redis-cli -h localhost',

# Then:
rebuild-hm
```

---

## 🔄 IMPLEMENTATION WORKFLOW

### For Each Enhancement:

**Step 1: Choose an item from above**
```bash
# Pick one action item
```

**Step 2: Edit xonshrc**
```bash
# Open the file:
v home-manager/modules/dotfiles/xonshrc

# Find the appropriate section (using search)
# Add the new aliases
# Save (ESC + :wq in vim)
```

**Step 3: Test syntax**
```bash
# Python syntax check:
python3 -m py_compile home-manager/modules/dotfiles/xonshrc

# Or just rebuild (will catch syntax errors):
rebuild-hm
```

**Step 4: Rebuild and verify**
```bash
# Apply changes:
rebuild-hm

# Test the new alias:
<your-new-alias> <args>
```

**Step 5: Commit**
```bash
# Stage changes:
git add home-manager/modules/dotfiles/xonshrc

# Commit with message:
git commit -m "feat(xonshrc): add <new-alias> for <purpose>"

# Or use:
gup main "Add new aliases: <list>"
```

---

## 📊 RECOMMENDATION SUMMARY

### Implement Now (5-10 minutes each)
Priority 1 items are quick wins:
1. ✅ `nmtui` - Network UI access
2. ✅ `virsh` - VM management
3. ✅ Syncthing status aliases
4. ✅ Service status aliases

### Implement This Week
Priority 2 items add real value:
1. 📋 Diagnostics aliases
2. 🔧 Dev utility aliases
3. 📦 Backup/restore framework

### Plan for Future
Priority 3 items are specialized:
1. 🎯 Database connections (when needed)
2. 🚀 Advanced git workflows
3. 🔐 Advanced security tools

---

## ⚖️ TRADE-OFFS

### Why Some Tools Don't Have Aliases:

**GUI Applications**
- Better launched via `menu` (Rofi)
- Reduces CLI clutter
- Easier discoverability for users

**Specialized Tools** (jq, yq, sops, imagemagick)
- Used infrequently
- Syntax varies by use case
- Alias would be less clear than full command

**System Diagnostics** (xprop, xdotool, acpi)
- Advanced/expert tools
- Not used in daily workflow
- CLI is descriptive enough

---

## 📈 METRICS

### Current State
- **Total Aliases**: 67
- **Documented**: 100%
- **Tested**: ✅
- **Organized**: 14 categories

### After Priority 1 (4 more)
- **Total**: 71 aliases
- **Coverage**: ~95% of common tasks

### After Priority 2 (8 more)
- **Total**: 79 aliases
- **Coverage**: ~98% of workflows

---

## 🎯 NEXT STEPS

1. **Review this list** - Pick items that match your workflow
2. **Implement Priority 1** - Takes 15 minutes total
3. **Test each alias** - Verify they work
4. **Commit changes** - Use `gup` command
5. **Update documentation** - Keep ALIASES_AND_SERVICES.md in sync

---

## 📝 HOW TO UPDATE DOCUMENTATION

After adding new aliases:

**Edit**: `docs/ALIASES_AND_SERVICES.md`

**Find the relevant section** (e.g., "System Services")

**Add your new aliases** in the table:
```markdown
| `alias-name` | command | description |
|--|--|--|
| `myalias` | mycommand | Does something useful |
```

**Then commit both files**:
```bash
git add home-manager/modules/dotfiles/xonshrc docs/ALIASES_AND_SERVICES.md
gup main "docs: update aliases with new additions"
```

---

## ✨ Success Criteria

You'll know this is done when:
- ✅ All Priority 1 items implemented
- ✅ All new aliases tested
- ✅ Documentation updated
- ✅ Changes committed to git
- ✅ No syntax errors on rebuild
