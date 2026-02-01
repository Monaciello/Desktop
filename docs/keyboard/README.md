# ZSA Keyboard Configuration Documentation

This directory contains complete documentation for the ZSA keyboard configuration in this NixOS setup.

---

## Files Overview

| File | Purpose | Audience |
|------|---------|----------|
| **layer-reference.md** | Complete layer reference, quick reference, troubleshooting | Everyone (start here!) |
| **PHASE-2-GUIDE.md** | Step-by-step guide for Layer 0-1 design (navigation) | Implementation Phase 2 |
| **PHASE-3-GUIDE.md** | Step-by-step guide for Layer 2 (dev/editor, HIGH PRIORITY) | Implementation Phase 3 |
| **PHASE-4-GUIDE.md** | Step-by-step guide for Layer 3 (window manager) | Implementation Phase 4 |
| **PHASE-5-GUIDE.md** | Step-by-step guide for Layer 4 (app launcher) | Implementation Phase 5 |
| **PHASE-6-GUIDE.md** | Optional: Context-aware automation with kontroll | Implementation Phase 6 |

---

## Quick Start

### For Setup Overview
Start with **layer-reference.md** - it contains:
- Hardware setup checklist
- All 5 layers explained with ASCII diagrams
- Priority alignment and what each layer addresses
- Troubleshooting quick reference
- Design philosophy

### For Hands-On Implementation
Follow phases in order, reading the corresponding guide:

1. **Phase 1** (DONE ✓): Hardware and system packages installed
   - See: `docs/keybindings.md` for system keybindings

2. **Phase 2**: Design Layer 0-1 (navigation)
   - Read: **PHASE-2-GUIDE.md**
   - Tools: `keymapp` GUI
   - Output: `home-manager/programs/zsa/layouts/base.kbd`

3. **Phase 3** (HIGH PRIORITY): Design Layer 2 (dev/editor + clipboard)
   - Read: **PHASE-3-GUIDE.md**
   - Tools: `keymapp` GUI
   - Output: `home-manager/programs/zsa/layouts/dev.kbd`

4. **Phase 4** (MEDIUM): Design Layer 3 (window manager)
   - Read: **PHASE-4-GUIDE.md**
   - Tools: `keymapp` GUI
   - Output: Updated kbd file with Layer 3

5. **Phase 5** (MEDIUM): Design Layer 4 (app launcher)
   - Read: **PHASE-5-GUIDE.md**
   - Tools: `keymapp` GUI
   - Output: `home-manager/programs/zsa/layouts/complete.kbd`

6. **Phase 6** (OPTIONAL): Setup automation with kontroll
   - Read: **PHASE-6-GUIDE.md**
   - Tools: kontroll daemon, shell scripts
   - Output: Context-aware layer switching

---

## Tools & Resources

### System Tools (Installed)
- **keymapp** - ZSA keyboard configuration GUI
- **wally-cli** - Firmware flasher for ZSA keyboards
- **kontroll** - Optional: Keyboard automation daemon

### Web Tools
- **Oryx Configurator** - https://configure.zsa.io (alternative to keymapp)

### Documentation
- **docs/keybindings.md** - System-wide keybindings reference (i3, tmux, nvim, etc.)
- **docs/wip.md** - Sprint tracking and TODO items

---

## Layer Overview (Quick Reference)

```
Layer 0: BASE
  Standard QWERTY typing

Layer 1: NAVIGATION (Hold Space)
  HJKL → Arrows, F1-F12, Home/End/PgUp/PgDn
  For: Cross-program navigation in nvim, browsers, terminals

Layer 2: DEV/EDITOR (Hold Enter) ⭐ HIGH PRIORITY
  Clipboard: Y/P for system yank/paste
  LSP: G(def), K(hover), R(rename), A(actions)
  Telescope: F(files), C(grep), B(buffers)
  Harpoon: 1-9 for bookmarks
  For: Fast editing with nixvim

Layer 3: WINDOW MANAGER (Hold Hyper)
  Workspaces: 1-0 for Alt+1-0
  Navigation: HJKL for Alt+HJKL (focus)
  Moving: Shift+HJKL for Alt+Shift+HJKL
  Modes: F(fullscreen), R(resize), G(gaps)
  Tmux: Thumb for Ctrl+Space prefix
  For: One-handed i3 + tmux control

Layer 4: APP LAUNCHER (Hold Meh)
  Apps: S/D/F/L/O/V for rofi/Discord/Flameshot/lf/Obsidian/Firefox
  Media: Volume, Brightness, Mute controls
  For: Quick app launching and media control

Layer 5: INTEGRATION (Optional, kontroll-based)
  Context-aware automation
  Auto-switch layers based on active app
```

---

## Key Decisions

### Why These Layers?
1. **Layer 0-1:** Foundation for cross-program navigation
2. **Layer 2:** HIGH PRIORITY addresses nixvim migration + clipboard gap (from wip.md)
3. **Layer 3:** Improves i3/tmux workflow (from wip.md integration patterns)
4. **Layer 4:** Convenience shortcuts and media controls
5. **Layer 5:** Optional automation for advanced users

### Muscle Memory Preservation
- Alt for i3 (already system default)
- Space as nvim leader (already configured)
- Ctrl+Space for tmux (already configured)
- HJKL navigation (already learned)

---

## File Locations

**Configuration Files:**
```
hosts/alice/hardware/keyboard.nix          - ZSA hardware support
hosts/alice/packages.nix                   - keymapp, wally-cli packages
home-manager/programs/zsa/default.nix      - Keyboard orchestration module
```

**Keyboard Layouts (create via keymapp GUI):**
```
home-manager/programs/zsa/layouts/
├── base.kbd          - Layer 0-1 (design in Phase 2)
├── dev.kbd           - Layer 0-2 (design in Phase 3)
└── complete.kbd      - Layer 0-4 (design in Phase 5)
```

**Automation (Phase 6, optional):**
```
home-manager/programs/zsa/automation/
├── kontroll.nix
└── scripts/
    ├── detect-app.sh
    ├── detect-nvim.sh
    └── switch-layer.sh
```

---

## Success Criteria

After completing all phases, you should have:

- [ ] Layer 0-1: Navigation works (Space+HJKL moves cursor in nvim)
- [ ] Layer 2: Clipboard and LSP shortcuts work (Y/P/gd/K in nvim)
- [ ] Layer 3: Workspace/window control works (Alt keybindings from keyboard)
- [ ] Layer 4: App launchers and media keys work
- [ ] No conflicts with system keybindings
- [ ] Firmware flashes without errors
- [ ] Documentation updated in keybindings.md

---

## Common Questions

**Q: Do I need all 5 layers?**
No. You can stop at Phase 2 (navigation only) and have a functional keyboard. Each phase builds on previous work.

**Q: Can I skip to Phase 3?**
No, each phase requires the previous to be set up. Follow in order: 2→3→4→5→6(optional).

**Q: What if keymapp won't start?**
Use Oryx web configurator: https://configure.zsa.io

**Q: Can I undo a phase?**
Yes. Just export the previous phase's .kbd file. All changes are non-destructive until you flash.

**Q: How do I test before flashing?**
keymapp has a preview/test mode. Test layer mappings in the GUI before flashing firmware.

---

## Troubleshooting

For quick fixes, see **layer-reference.md** "Troubleshooting Quick Guide" section.

For phase-specific issues:
- Phase 2: See PHASE-2-GUIDE.md "Troubleshooting"
- Phase 3: See PHASE-3-GUIDE.md "Troubleshooting"
- Phase 4: See PHASE-4-GUIDE.md "Troubleshooting"
- Phase 5: See PHASE-5-GUIDE.md "Troubleshooting"
- Phase 6: See PHASE-6-GUIDE.md "Troubleshooting"

---

## Next Steps

1. Read **layer-reference.md** for overview and design philosophy
2. Read **PHASE-2-GUIDE.md** to start hands-on implementation
3. Launch `keymapp` and begin designing Layer 0-1
4. Follow the guides phase-by-phase

**Ready? Start with: `layer-reference.md`**
