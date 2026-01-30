# Options Audit | 2026-01-30

Quick reference for enabled/disabled options. Ask: *why is this on/off?*

## System (hosts/alice/)

### Audio

| Option | State | Why |
|--------|:-----:|-----|
| `services.pipewire` | on | Modern audio server, replaces PulseAudio |
| `services.pipewire.alsa` | on | ALSA compatibility layer |
| `services.pipewire.pulse` | on | PulseAudio API compatibility |
| `services.pulseaudio` | **off** | Conflicts with pipewire |

### Security

| Option | State | Why |
|--------|:-----:|-----|
| `networking.firewall` | on | Block unauthorized inbound |
| `services.openssh` | on | Remote access (PermitRootLogin=no) |
| `security.sudo` | on | Privilege escalation |
| `security.sudo.wheelNeedsPassword` | **off** | Convenience - FIXME for prod |
| `security.rtkit` | on | Realtime scheduling for pipewire |

### Network & Hardware

| Option | State | Why |
|--------|:-----:|-----|
| `networking.networkmanager` | on | WiFi/VPN management |
| `services.tailscale` | on | Mesh VPN |
| `services.blueman` | on | Bluetooth GUI |
| `services.fstrim` | on | SSD TRIM for longevity |
| `services.thermald` | on | CPU thermal management |
| `powerManagement.powertop` | on | Power optimization |
| `services.power-profiles-daemon` | **off** | Conflicts with powertop |

### Desktop

| Option | State | Why |
|--------|:-----:|-----|
| `displayManager.lightdm` | on | Minimal login manager |
| `windowManager.i3` | on | Tiling WM |
| `displayManager.autoLogin` | on | Skip login screen (single user) |
| `programs.firefox` | on | System-wide browser |

### Virtualization

| Option | State | Why |
|--------|:-----:|-----|
| `virtualisation.libvirtd` | on | KVM/QEMU backend |
| `programs.virt-manager` | on | VM GUI |

### Nix

| Option | State | Why |
|--------|:-----:|-----|
| `boot.loader.systemd-boot` | on | UEFI bootloader |
| `nix.channel` | **off** | Flakes-only workflow |
| `documentation.*` | on | Man pages, dev docs |

---

## User (home-manager/)

| Program | State | Config Style | Notes |
|---------|:-----:|--------------|-------|
| `programs.home-manager` | on | minimal | Self-management |
| `programs.git` | on | declarative | SSH signing enabled |
| `programs.tmux` | on | hybrid | extraConfig for keybinds |
| `programs.kitty` | on | declarative | Custom Nord-ish theme |
| `programs.neovim` | on | hybrid | External init.lua |

---

## Typing Opportunities

| Current | Better | Benefit |
|---------|--------|---------|
| `tmux.extraConfig` | typed `tmux.*` options | Validation, completion |
| `neovim` + file | `extraLuaConfig` | Single source of truth |
| kitty inline colors | theme module | Reuse across apps |

---

**Totals:** 24 on | 3 off | 2 hybrid configs

*Review quarterly. Each "off" should have a reason.*
