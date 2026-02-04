# Aliases & Services Documentation Index

Quick navigation for all aliases, services, and enhancement information.

---

## 📚 Documentation Files

### 1. **ALIASES_AND_SERVICES.md** - Complete Reference
**What**: Full catalog of everything installed
**When to use**: Looking up how to use something, understanding what's available
**Size**: 369 lines

**Contains**:
- Quick reference (most frequently used aliases)
- All 67 aliases organized by category
- Complete services documentation
- Programs without aliases (explained)
- Status summary

**Quick access**:
```bash
cat docs/ALIASES_AND_SERVICES.md
```

---

### 2. **ACTION_ITEMS.md** - Enhancement Guide
**What**: Specific improvements with implementation steps
**When to use**: Ready to add new functionality
**Size**: 423 lines

**Contains**:
- Completed items (no action needed)
- Priority 1: Quick wins (5-10 min each)
- Priority 2: Medium effort, high value
- Priority 3: Advanced features
- Step-by-step implementation instructions
- Code snippets ready to use
- Testing & verification steps

**Quick access**:
```bash
cat docs/ACTION_ITEMS.md
```

---

## 🎯 Quick Navigation

### I want to...

#### Find an alias
```bash
grep "alias-name" docs/ALIASES_AND_SERVICES.md
```

#### Use a specific command
**Example**: Manage files
```bash
# Read section: "📁 File & Navigation" in ALIASES_AND_SERVICES.md
fm          # File manager
ls, ll, la  # Directory listing
tree        # Tree view
```

#### Add a new alias
1. Read: `docs/ACTION_ITEMS.md` → Choose a Priority 1 item
2. Edit: `home-manager/modules/dotfiles/xonshrc`
3. Follow: Step-by-step instructions from ACTION_ITEMS.md
4. Test: `rebuild-hm` then test the alias
5. Commit: `gup main "feat(xonshrc): add <alias>"`

#### Understand a service
```bash
grep -A 5 "NetworkManager\|PipeWire\|openssh" docs/ALIASES_AND_SERVICES.md
```

#### See what's missing
```bash
grep -A 10 "without aliases" docs/ALIASES_AND_SERVICES.md
```

---

## 🚀 Common Tasks

### Daily Use
- View docs: `cat docs/ALIASES_AND_SERVICES.md | less`
- Edit alias: `v home-manager/modules/dotfiles/xonshrc`
- Rebuild: `rebuild-hm`

### Development
- Check available tools: Search for your tool in ALIASES_AND_SERVICES.md
- Find linters/formatters: Search "Development & Formatting" section
- Add new alias: Follow ACTION_ITEMS.md Priority 1

### System Administration
- Check services: Search "System Services" in ALIASES_AND_SERVICES.md
- Diagnose: See "System Diagnostics" recommendations in ACTION_ITEMS.md
- Monitor: `top`, `ipv4`, service status aliases

---

## 📊 Quick Stats

| Category | Count | Status |
|----------|-------|--------|
| Aliases | 67 | ✅ Documented |
| Services | 15+ | ✅ Documented |
| Programs | 60+ | ✅ Documented |
| GUI Apps | 10 | ✅ Via Rofi |
| Possible Enhancements | 16 | 📋 Documented |

---

## 🔍 Find Things Fast

### By Frequency of Use

**Daily**:
- `rebuild-hm` - Home manager rebuild (fastest)
- `v`, `e` - Edit with neovim
- `ls`, `ll`, `la`, `lla` - Directory listing
- `fmt` - Format Nix files
- `vol+`, `vol-` - Volume control

**Weekly**:
- `wp` - Wallpaper management
- `top` - System monitoring
- `gup` - Git sync
- `ss` - Screenshot
- `menu` - App launcher

**Monthly**:
- System service checks
- Display profile changes (`d`)
- Update system (`rebuild-all`)

**As Needed**:
- Specialized tools (jq, sops, imagemagick)
- GUI apps via `menu`
- System diagnostics

---

### By Type

**File Operations**:
```bash
fm, ls, ll, la, lla, cat, tree, bak, untar, path_of
```

**System Management**:
```bash
rebuild-all, rebuild-hm, rebuild-sys, top, ipv4
```

**Development**:
```bash
v, e, fmt, lint-nix, lint-sh, test, search
```

**Media & Control**:
```bash
play, playnext, playprev, vol+, vol-, bright+, bright-, ss, obs
```

**Utilities**:
```bash
menu, emoji, lock, wp, d, gup, xc, decrypt, encrypt
```

---

## 💡 Tips

### Performance
- Use `rebuild-hm` for faster builds (skips system)
- Use `rebuild-all` for full changes
- Use `rebuild-sys` if only system config changed

### Workflow
- Always run `fmt` before committing Nix files
- Use `gup` instead of direct git commands (safer)
- Test new aliases with `<alias> --help` first

### Documentation
- Update `ALIASES_AND_SERVICES.md` after adding aliases
- Use same section ordering as xonshrc
- Add verification steps to ACTION_ITEMS.md for new items

---

## ✅ Verification Checklist

After adding new aliases:

- [ ] Edited xonshrc
- [ ] Ran `rebuild-hm` without errors
- [ ] Tested new alias works
- [ ] Updated ALIASES_AND_SERVICES.md
- [ ] Committed with `gup`

---

## 📖 Full Documentation Links

- **Reference**: `docs/ALIASES_AND_SERVICES.md` (what you have)
- **Implementation**: `docs/ACTION_ITEMS.md` (what to add)
- **Keybindings**: `docs/keybindings.md` (i3 keybinds)
- **Work in Progress**: `docs/wip.md` (current projects)

---

## 🎓 Learning Path

### Beginner
1. Read "Quick Reference" in ALIASES_AND_SERVICES.md
2. Try daily aliases (ls, cat, v, fmt)
3. Use `rebuild-hm` workflow

### Intermediate
1. Explore all 67 aliases
2. Understand service documentation
3. Implement Priority 1 enhancements (ACTION_ITEMS.md)

### Advanced
1. Implement Priority 2 items
2. Create custom aliases for your workflow
3. Integrate new services as needed

---

## 🆘 Troubleshooting

**Alias not working after rebuild**:
```bash
# Restart shell
exit
# or
source ~/.xonshrc
```

**Syntax error in xonshrc**:
```bash
python3 -m py_compile home-manager/modules/dotfiles/xonshrc
# or just rebuild (will show error):
rebuild-hm
```

**Lost alias changes**:
```bash
git diff home-manager/modules/dotfiles/xonshrc
git checkout -- home-manager/modules/dotfiles/xonshrc
```

---

## 📞 Support Commands

```bash
# Show all aliases:
alias

# Search for specific alias:
grep "alias-name" docs/ALIASES_AND_SERVICES.md

# Check alias definition:
which <alias>

# Show recent commands:
history | grep <partial-command>

# Get help:
<command> --help
<command> -h
```

---

Last Updated: 2026-02-04
Status: ✅ Complete and ready to use
