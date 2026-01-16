# NixOS Configuration Decisions

## Desktop Environment
1. **WM**: i3 (X11) ✓
2. **Display server**: X11 ✓
3. **Fallback DE**: None (no Cinnamon)
4. **Launcher**: Rofi ✓
5. **Status bar**: i3blocks ✓

## Terminal & Shell
6. **Terminal**: Kitty (GPU-accel, tmux auto-launch) ✓
7. **Shell**: Xonsh (Python-based) ✓
8. **Tmux**: vim keybinds, C-Space prefix, minimal-status, declarative plugins ✓

## Editor
9. **Neovim**: lazy.nvim, LSP, Telescope, Harpoon, Treesitter, Obsidian.nvim, vim-tmux-navigator ✓

## Theming
10. **Colors**: #0f1c21 background, Nordic accents ✓
11. **Fonts**: Cascadia Code, JetBrains Mono Nerd ✓
12. **Borders**: 1px, no title bars, gaps (10 inner, 2 outer) ✓
13. **Compositor**: picom, kitty 85% / obsidian 90% transparency, vsync ✓
14. **GTK**: Adapta-Nokto theme, Papirus-Dark icons, Bibata cursor ✓

## System
15. **Audio**: PipeWire + PulseAudio compat ✓
16. **Power**: TLP (performance AC, powersave battery) ✓
17. **Bluetooth**: Blueman ✓
18. **Printing**: Not needed ✗

## Networking
19. **Services**: Tailscale ✓, Syncthing ✓, NetworkManager ✓

## Virtualization
20. **VMs**: virt-manager/libvirt ✓

## Applications
21. **Browsers**: Firefox, Tor ✓
22. **Media**: VLC, OBS ✓
23. **Office**: LibreOffice, Obsidian, Zathura, Xournalpp, Anki ✓
24. **Communication**: Discord ✓
25. **Dev**: VSCodium ✓
26. **CLI**: eza, bat, fzf, ripgrep, zoxide, btop, fastfetch, flameshot ✓

## Keybindings
27. **Scheme**: Alt primary mod, vim hjkl navigation ✓
28. **Media keys**: pamixer, brightnessctl, playerctl ✓

## Dev Tools
29. **Languages**: Python3 + uv ✓, Lua/LuaRocks (neovim) ✓
30. **Skip**: GCC/Clang/GDB, Java

## Misc
31. **Login**: lightdm auto-login ✓
32. **SSD**: TRIM enabled ✓
33. **Clipboard**: xclip ✓

---

## Implementation Status

### Completed
- Declarative tmux (no TPM needed)
- xontrib-uvox packaged (replaces vox, uses uv)
- Dev tools moved to shells/default.nix
- Layer separation (system/user/project)

### Manual Setup Required
1. `ln -s ~/Projects/nixos ~/.config/nixos`
2. `mkdir -p ~/Pictures/wallpapers && cp <image> ~/Pictures/wallpapers/wallpaper`

### Build Fixes Applied
- GoogleDot-White → Bibata-Modern-Classic cursor
- XDG portal config.common.default = "*"
- License format patch for xontrib-uvox (PEP 639 → PEP 621)

### Skipped
- cybersecurity.nix, hyprland/waybar/wofi, bash.nix, gdb.nix, catppuccin.nix

---

## Xonsh & xontrib-uvox Configuration

### Global Behavior
34. **Tracebacks**: `$XONSH_SHOW_TRACEBACK = True` — Keep for debugging? ___
35. **Wallpaper dir**: `~/Pictures/wallpapers` exists? ___

### Prompt
36. **Show nix shell name**: `{nix_shell_name}` — Keep? ___
37. **Show venv name**: `{env_name_cust}` — Keep? ___
38. **Prompt colors**: BLACK/CYAN/WHITE/#CCFFFF — Adjust? ___

### Desktop Functions
39. **set_wallpaper**: Assumes i3 — Correct WM? ___
40. **set_display**: Uses autorandr — Installed? ___
41. **Multiple displays**: Need autorandr profiles? ___

### Git Workflow
42. **gup (git_sync)**: Dangerous (git add ., auto-push) — Keep/Remove/Replace? ___
43. **Add safe git aliases**: gst, gco, gd, gc? ___

### PATH
44. **~/.local/bin in PATH**: Keep? ___

### xontrib-uvox
45. **uvox confirmed**: Using uv-based venv manager ✓
46. **Virtualenv location**: Default `~/.virtualenvs`? ___
47. **mkvenv behavior**: `uvox new venv` in project dir? ___

### Aliases Audit
48. **code → codium**: Correct? ___
49. **neo → fastfetch**: Keep? ___
50. **webup**: HTTP server on 8080 — Keep? ___
51. **tkill**: Kills ALL tmux sessions — Keep? ___
52. **untar**: Only .tar.xz, make generic? ___

### Zoxide
53. **cd replacement**: Comfortable with zoxide as cd? ___

### Dependencies Check
54. **Installed**: eza, bat, zoxide, fastfetch, xclip, autorandr? ___
55. **Python available**: Via xontrib-uvox dependency ✓

### Home Manager
56. **xonshrc via home.file**: Keep this approach? ___
57. **Auto-create dirs**: ~/Pictures/wallpapers, ~/.local/bin? ___

### Dead Code
58. **command_output()**: Unused function — Remove? ___

---

## Package Locations

```
SYSTEM (hosts/alice/default.nix):
  i3, lightdm, picom, openssh, pipewire, bluetooth
  autorandr, xclip, brightnessctl, pamixer

USER (home-manager/home.nix):
  xontrib-uvox (brings xonsh+uv), kitty, tmux
  eza, bat, fzf, ripgrep, zoxide, btop, fastfetch
  firefox, obsidian, discord, vscodium-fhs, vlc

PROJECT (shells/default.nix):
  python3, uv, shellcheck, bats, alejandra, jq
```

---

## Keybind Reference

```
i3:  Alt+Return=term  Alt+s=rofi  Alt+hjkl=focus  Alt+Shift+q=kill
     Alt+1-0=workspaces  Win+v=firefox  Win+o=obsidian  Win+l=lf

tmux: Ctrl+Space=prefix  prefix+hjkl=panes  prefix+c=new  prefix+b=status

xonsh aliases:
  rebuild/hms     NixOS/home-manager rebuild
  v/c             nvim/clear
  ls/ll/la/cat    eza/bat replacements
  wp/d            wallpaper/display
  vac/vdac/vls    uvox activate/deactivate/list
  mkvenv          uvox new venv
  gup             git sync (dangerous)
  ipv4/webup      local IP / HTTP server
```

---

## i3blocks Scripts
- battery (acpi)
- cpu_usage (sysstat)
- volume (pactl)
- network (tailscale, ip)
- disk (df)
- datetime (date)
- application (xdotool, xprop)

---

## Neovim Configuration Structure

### Section 0-1: Foundation
- **Leader key**: Spacebar
- **Lazy bootstrap**: Auto-downloads plugin manager if missing

### Section 2: Plugin List
```
Visuals:    airline (statusbar), alpha-nvim (dashboard), transparent.nvim
Navigation: telescope (fuzzy find), harpoon (quick switch), tmux-navigator
Writing:    obsidian.nvim, vim-table-mode
Coding:     treesitter (syntax), lsp-zero (IDE features)
```

### Section 3: Plugin Config
- **Treesitter (3.1)**: Language parsers for syntax/highlighting
- **Telescope (3.2)**: Ignore .git, __pycache__, etc.
- **Obsidian (3.3)**: Vault path ~/obsidian
- **LSP/cmp (3.6)**: Mason (tool installer) + autocomplete menu
- **Image.nvim (3.7)**: View images in Kitty terminal

### Section 4: Autocommands
- Strip trailing whitespace on save
- Force UI colors for consistency (borders, menus, notifications)

### Section 5: Keymaps
```
Ctrl+o      Find files          Ctrl+f      Search text
Ctrl+b      Toggle terminal     Ctrl+s      Save file
Space+a     Harpoon mark        Alt+j/k     Move line down/up
```

### Section 6: Options
```
relativenumber = true     Line numbers relative to cursor
tabstop = 2               2-space indentation
ignorecase/smartcase      Smart search like browser
swapfile = false          No swap (use git instead)
```

### Neovim Questions
59. **LSP languages**: Add/remove from Mason? ___
60. **Obsidian vault**: Path ~/obsidian correct? ___
61. **Image.nvim**: Using Kitty terminal? ___
62. **Keymaps**: Modify any shortcuts? ___
