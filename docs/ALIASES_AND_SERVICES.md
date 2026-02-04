# Aliases and Services Guide

Complete reference for all aliases, services, and programs in this NixOS configuration.

---

## Quick Reference

### Most Frequently Used Aliases

```bash
# Navigation & Files
ls, ll, la, lla          # Enhanced directory listing
fm                       # File manager (lf)
cat                      # View files with syntax highlighting

# Editors & Development
v, e                     # Edit with nvim
fmt                      # Format Nix files
lint-nix, lint-sh        # Lint code

# System Management
rebuild-hm               # Quick: rebuild home-manager only
rebuild-sys              # Full: rebuild NixOS system
rebuild-all              # Both: system + home-manager
rebuild                  # Default: home-manager

# Media & System Control
vol+, vol-               # Volume control
bright+, bright-         # Brightness control
play, playnext, playprev # Media player control
top                      # System monitoring

# Quick Access
menu                     # App launcher (rofi)
emoji                    # Emoji picker
lock                     # Screen lock
ss                       # Screenshot
```

---

## Complete Aliases List (67 Total)

### 🔧 System Management (5)
| Alias | Command | Purpose |
|-------|---------|---------|
| `rebuild-sys` | sudo nixos-rebuild switch | Rebuild NixOS system only |
| `rebuild-hm` | home-manager switch | Rebuild home-manager only |
| `rebuild-all` | Both commands | Full system + user rebuild |
| `rebuild` | home-manager switch | Default: home-manager (faster) |
| `hm` | home-manager switch | Alias for home-manager |

### 📁 File & Navigation (10)
| Alias | Command | Purpose |
|-------|---------|---------|
| `ls` | eza --icons | Enhanced directory listing |
| `ll` | eza --icons -l | Long format listing |
| `la` | eza --icons -a | Show hidden files |
| `lla` | eza --icons -la | Long format + hidden |
| `cat` | bat | View files with syntax highlighting |
| `fm` | lf | Terminal file manager |
| `tree` | tree -I filters | Directory tree view |
| `search` | rg | Ripgrep (fast search) |
| `top` | btop | Better system monitor |
| `path_of` | pwd/$arg0 | Show full path |

### 📝 Text Editing (2)
| Alias | Command | Purpose |
|-------|---------|---------|
| `v` | nvim | Edit with neovim |
| `e` | nvim | Alternative editor shortcut |

### 🛠️ Development & Formatting (4)
| Alias | Command | Purpose |
|-------|---------|---------|
| `fmt` | nixfmt | Format Nix files |
| `lint-nix` | statix check | Lint Nix code |
| `lint-sh` | shellcheck | Lint shell scripts |
| `test` | bats | Run Bash tests |

### 🎨 GUI Applications (10)
| Alias | Command | Purpose |
|-------|---------|---------|
| `vlc` | vlc | Media player |
| `obs` | obs-studio | Screen recording |
| `ss` | flameshot gui | Screenshot tool |
| `doc` | obsidian | Notes (Obsidian) |
| `pdf` | zathura | PDF viewer |
| `draw` | xournalpp | Drawing/annotation |
| `study` | anki | Flashcard learning |
| `msg` | discord | Chat/voice |
| `ide` | vscodium-fhs | Code editor |
| `code` | codium | Alternative IDE |

### 🪟 Window Manager & Desktop (4)
| Alias | Command | Purpose |
|-------|---------|---------|
| `menu` | rofi -show drun | Application launcher |
| `emoji` | rofimoji -a copy | Emoji picker |
| `lock` | i3lock-fancy | Screen lock |
| `vm` | virt-manager | Virtual machine manager |

### 🔊 Media & System Control (8)
| Alias | Command | Purpose |
|-------|---------|---------|
| `play` | playerctl play-pause | Play/pause media |
| `playnext` | playerctl next | Next track |
| `playprev` | playerctl previous | Previous track |
| `vol+` | pactl +5% | Increase volume |
| `vol-` | pactl -5% | Decrease volume |
| `bright+` | brightnessctl +5% | Increase brightness |
| `bright-` | brightnessctl -5% | Decrease brightness |

### 📊 System Information (2)
| Alias | Command | Purpose |
|-------|---------|---------|
| `neo` | fastfetch | System information |
| `sysinfo` | fastfetch | Alternative sysinfo |

### 🔐 Utilities & Tools (6)
| Alias | Command | Purpose |
|-------|---------|---------|
| `untar` | Safe tar extraction | Extract archives safely |
| `tkill` | tmux kill-server | Kill all tmux sessions |
| `xc` | xclip -selection c | Copy to clipboard |
| `bak` | cp $arg0 $arg0.bak -r | Create backups |
| `decrypt` | age -d | Decrypt files |
| `encrypt` | age -e | Encrypt files |

### 🐍 Python Virtual Environments (4)
| Alias | Command | Purpose |
|-------|---------|---------|
| `mkvenv` | uvox new venv | Create venv |
| `vac` | uvox activate | Activate venv |
| `vdac` | uvox deactivate | Deactivate venv |
| `vls` | uvox list | List venvs |

### 📚 Git & Version Control (1)
| Alias | Command | Purpose |
|-------|---------|---------|
| `gup` | git_sync | Safe git workflow with confirmations |

### 🖼️ Wallpaper & Display (2)
| Alias | Command | Purpose |
|-------|---------|---------|
| `wp` | set_wallpaper | Manage wallpapers |
| `d` | set_display | Change display profile |

### 🌐 Network & Internet (1)
| Alias | Command | Purpose |
|-------|---------|---------|
| `ipv4` | get_local_ip | Show local IP address |

### 🌐 Web Development (1)
| Alias | Command | Purpose |
|-------|---------|---------|
| `webup` | python3 http.server 8080 | Local dev server (⚠️ local only) |

### ✨ Common Shortcuts (4)
| Alias | Command | Purpose |
|-------|---------|---------|
| `c` | clear | Clear screen |
| `q` | exit | Exit shell |

---

## System Services

### ✅ Active Services

#### Network Services
- **networkmanager** - WiFi/network management
  - CLI: `nmcli`, TUI: `nmtui` (no alias - use rofi)
  - Status: `systemctl status NetworkManager`

- **tailscale** - VPN (encrypted WireGuard)
  - CLI: `tailscale status`, `tailscale ip -4`
  - Status: `systemctl status tailscale`

- **syncthing** - File synchronization
  - Web UI: `http://localhost:8384`
  - CLI: Limited (mainly background service)

#### Audio/Media Services
- **pipewire** - Modern audio server (replaces pulseaudio)
  - Control: `pactl` (volume aliases: `vol+`, `vol-`)
  - Brightness: `brightnessctl` (aliases: `bright+`, `bright-`)
  - Media: `playerctl` (aliases: `play`, `playnext`, `playprev`)

#### Security Services
- **openssh** - Secure shell server
  - CLI: `ssh`, `scp`, `ssh-keygen`
  - Status: `systemctl status sshd`

- **fail2ban** - Intrusion prevention
  - CLI: `fail2ban-client status`
  - Status: `systemctl status fail2ban`

#### Virtualization
- **libvirtd** - KVM/QEMU virtualization
  - CLI: `virsh` (no alias - advanced)
  - GUI: `virt-manager` (alias: `vm` ✓)

#### Desktop Services
- **i3** - Window manager (started by X11)
- **pipewire** - Audio daemon

---

## Programs Without Aliases (But Valuable)

### Why They Don't Have Aliases

#### GUI Programs (Launch from Rofi via `menu`)
- `tor-browser` - Privacy browser
- `libreoffice` - Office suite
- Can also use: `wmctrl`, `xdotool` for launching

#### Occasional Use Tools
- `jq` - JSON query tool (use when needed: `jq .`)
- `yq` - YAML query tool
- `sops` - Secrets management
- `imagemagick` - Image processing

#### System/X11 Diagnostic Tools
- `xdotool` - X11 automation
- `acpi` - Power/battery info
- `sysstat` - System statistics
- `xorg.xprop` - Window property viewer
- `xorg.xdpyinfo` - Display info

#### Keyboard Configuration
- `keymapp` - ZSA Keyboard config (GUI)
- `wally-cli` - ZSA Firmware flasher

#### Desktop Theme Configuration
- `lxappearance` - GTK theme picker (or use gtk.nix)
- `arandr` - Display GUI (use `d` alias for autorandr instead)

---

## Services & Programs by Category

### 🌍 Network & Connectivity
| Service | Status | Control | Alias |
|---------|--------|---------|-------|
| NetworkManager | ✅ Active | nmcli/nmtui | - |
| Tailscale | ✅ Active | tailscale CLI | - |
| Syncthing | ✅ Active | Web UI:8384 | - |
| OpenSSH | ✅ Active | ssh/scp | - |

### 🔊 Audio & Media
| Tool | Control | Alias |
|------|---------|-------|
| PipeWire | pactl | vol±, play, playnext, playprev |
| Brightness | brightnessctl | bright±  |
| Screenshots | flameshot | ss |

### 🖥️ Desktop & Display
| Tool | Control | Alias |
|------|---------|-------|
| i3 (WM) | i3 config | - |
| Rofi (Launcher) | rofi | menu |
| Display Profiles | autorandr | d |
| Wallpaper | feh | wp |

### 🔐 Security
| Service | Control | Notes |
|---------|---------|-------|
| fail2ban | fail2ban-client | Intrusion prevention |
| OpenSSH | ssh/scp | Remote access |
| Firewall | ufw/firewall | Host-based |

### 🛠️ Development
| Tool | Alias | Purpose |
|------|-------|---------|
| nixfmt | fmt | Format Nix code |
| statix | lint-nix | Lint Nix code |
| shellcheck | lint-sh | Lint shell scripts |
| bats | test | Bash testing |

---

## Usage Recommendations

### Daily Use
- `rebuild-hm` - Fast iteration on configs
- `fmt` - Before committing Nix changes
- `v` - Edit files
- `ls`, `ll`, `la` - Directory navigation
- `vol±`, `bright±` - Quick adjustments
- `wp` - Change wallpaper

### Development
- `fmt`, `lint-nix`, `lint-sh` - Code quality
- `test` - Run tests
- `tree` - Project structure
- `search` - Find code

### System Administration
- `rebuild-all` - Full system update
- `top` - Monitor system
- `ipv4` - Network diagnostics
- `gup` - Safe git sync
- `vm` - Virtual machines

### Media & Entertainment
- `play`, `playnext`, `playprev` - Media control
- `ss` - Screenshots
- `obs` - Screen recording
- `vlc` - Video playback

---

**For enhancement suggestions and implementation guides, see**: `docs/ACTION_ITEMS.md`

---

## File Locations

### Configuration Files
- Aliases: `home-manager/modules/dotfiles/xonshrc` (line 266+)
- Services: `hosts/alice/services/`
- GTK Theme: `home-manager/modules/gtk.nix`
- Wallpaper: `home-manager/modules/wallpaper.nix`
- i3 Config: `home-manager/modules/dotfiles/i3.conf`

### Systemd Services
- User services: `~/.config/systemd/user/`
- System services: `/etc/systemd/system/` (NixOS managed)

---

## Status Summary

✅ **Comprehensive Coverage**
- 67 total aliases covering all major workflows
- All frequently-used programs have shortcuts
- System services documented and accessible

⚠️ **Areas for Consideration**
- Some GUI apps better launched via Rofi (`menu`)
- Advanced tools (jq, sops, imagemagick) are specialized
- System diagnostics tools rarely used directly from CLI

📝 **Documentation**
- All aliases documented and categorized
- Services clearly identified
- Usage recommendations provided
