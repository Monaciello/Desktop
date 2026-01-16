# NixOS Configuration: Design & Development Guide

## Architecture Overview

```
nix-starter-config (base)
        │
        ▼
┌───────────────────┐     ┌───────────────────┐
│   flake.nix       │────▶│   skarabox        │ (future: multi-host)
│   (entry point)   │     │   selfhostblocks  │ (future: services)
└───────────────────┘     └───────────────────┘
        │
        ├── hosts/alice/          # SYSTEM layer (NixOS)
        │   ├── default.nix       #   hardware, services, system pkgs
        │   ├── hardware-configuration.nix
        │   └── secrets.nix       #   sops-nix encrypted secrets
        │
        ├── home-manager/         # USER layer (home-manager)
        │   ├── home.nix          #   user pkgs, programs.* configs
        │   └── modules/          #   dotfiles (i3, kitty, neovim...)
        │
        ├── shells/               # PROJECT layer (devShells)
        │   └── default.nix       #   dev environments (xonsh-based)
        │
        ├── overlays/             # Package modifications
        ├── pkgs/                 # Custom packages (empty)
        └── modules/              # Reusable modules (empty, for export)
```

---

## Design Principles

### 1. Layer Separation (Immutable Boundaries)

| Layer   | Location              | Managed By      | Contains                    |
|---------|-----------------------|-----------------|------------------------------|
| SYSTEM  | `hosts/<hostname>/`   | `nixos-rebuild` | boot, services, hardware     |
| USER    | `home-manager/`       | `home-manager`  | dotfiles, user apps          |
| PROJECT | `shells/`             | `nix develop`   | dev tools, language runtimes |
| RUNTIME | `.venv/`, etc.        | uv, npm, cargo  | project dependencies         |

**Rule**: Never leak between layers. Dev tools don't belong in USER. User apps don't belong in SYSTEM.

### 2. Single Shell Philosophy

**Xonsh everywhere** - Python superset that runs shell commands:
- Login shell: xonsh
- Dev shells: xonsh
- Scripts: xonsh/python (same syntax)
- No POSIX fragility, full Python stdlib

### 3. Declarative Over Imperative

| Before (Imperative)                  | After (Declarative)                |
|--------------------------------------|------------------------------------|
| `git clone tpm && prefix+I`          | `programs.tmux.plugins = [...]`    |
| `pip install xontrib-vox`            | `shells/default.nix` with uv       |
| Manual dotfile symlinks              | `home.file.".config/..." = ...`    |

### 4. Reproducibility Chain

```
flake.lock (pinned inputs)
    │
    ▼
flake.nix (declares what to build)
    │
    ▼
nix build/develop (hermetic evaluation)
    │
    ▼
/nix/store/... (immutable outputs)
```

---

## Development Phases

### Phase 0: Bootstrap (COMPLETE)
- [x] Adapt nix-starter-config structure
- [x] Configure hosts/alice with hardware-configuration.nix
- [x] Setup sops-nix for secrets
- [x] Basic home-manager integration

### Phase 1: Workstation Config (COMPLETE)
- [x] i3 window manager with keybindings
- [x] Kitty terminal + tmux (declarative plugins)
- [x] Neovim with lazy.nvim
- [x] Xonsh shell with aliases
- [x] GTK theming (Adapta-Nokto)
- [x] i3blocks status bar scripts
- [x] devShells exposed in flake

### Phase 2: Layer Cleanup (COMPLETE)
- [x] Remove duplicates between system/user
- [x] Move dev tools to shells/
- [x] Convert tmux to declarative (no TPM)
- [x] Document layer boundaries

### Phase 3: VM Testing & Validation (CURRENT)
- [ ] Build VM: `nix build .#nixosConfigurations.alice.config.system.build.vm`
- [ ] Test in QEMU
- [ ] Validate all services start
- [ ] Test home-manager activation

### Phase 4: Multi-Host Preparation (PLANNED)
- [ ] Extract common config to `hosts/common/`
- [ ] Create second host template
- [ ] Setup deployment strategy (colmena or deploy-rs)
- [ ] Per-host secrets structure

### Phase 5: Skarabox Integration (PLANNED)
- [ ] Import skarabox modules
- [ ] Configure server host
- [ ] Setup selfhostblocks services:
  - [ ] Vaultwarden (passwords)
  - [ ] Forgejo (git)
  - [ ] Nextcloud (files)
- [ ] IAM: least-privilege user/service accounts

### Phase 6: Sovereign Infrastructure (FUTURE)
- [ ] Monitoring (Prometheus/Grafana)
- [ ] Backup strategy
- [ ] VPN mesh (Tailscale/Headscale)
- [ ] CI/CD for config changes

---

## Quick Reference

### Commands
```bash
# Rebuild system
sudo nixos-rebuild switch --flake ~/.config/nixos#alice

# Rebuild home (standalone)
home-manager switch --flake ~/.config/nixos#sasha@alice

# Enter dev shell
nix develop .#dev

# Check flake
nix flake check --show-trace

# Build VM for testing
nix build .#nixosConfigurations.alice.config.system.build.vm
./result/bin/run-alice-vm

# Format nix files
nix fmt
```

### Xonsh Aliases (from ~/.xonshrc)
```
rebuild  → sudo nixos-rebuild switch --flake ~/.config/nixos
hms      → home-manager switch --flake ~/.config/nixos
v        → nvim
ls/ll/la → eza variants
cat      → bat
```

### Keybindings (i3)
```
Alt+Return      Terminal (kitty)
Alt+s           Launcher (rofi)
Alt+h/j/k/l     Focus navigation
Alt+Shift+q     Kill window
Alt+1-0         Workspaces
Win+v           Firefox
Win+o           Obsidian
Win+l           lf (file manager)
```

### Keybindings (tmux, prefix = Ctrl+Space)
```
prefix+h/j/k/l  Pane navigation
prefix+c        New window
prefix+%        Split horizontal
prefix+"        Split vertical
Ctrl+Alt+hjkl   Resize panes
```

---

## File Changelog

### From nix-starter-config
- `flake.nix` - Extended with skarabox, sops-nix, nixos-anywhere inputs
- `overlays/default.nix` - Unchanged (additions, modifications, unstable)
- `pkgs/default.nix` - Empty, documented for future custom packages
- `modules/` - Empty, for exportable modules

### From PrettyBoyCosmo/Dotfiles
- `home-manager/modules/` - Adapted i3, kitty, neovim, rofi, picom, xonsh
- `home-manager/modules/dotfiles/` - Config files and i3blocks scripts
- Customized for user `sasha`, removed bluecosmo-specific paths

### Custom Additions
- `shells/default.nix` - devShells (default, dev, fhs, xonsh)
- `hosts/alice/secrets.nix` - sops-nix integration
- Declarative tmux with `mkTmuxPlugin` for minimal-tmux-status

---

## Security Model

### Secrets (sops-nix)
```
secrets/
└── alice.yaml    # Encrypted with age key

# Decrypted at activation to:
/run/secrets/...  # tmpfs, not persisted
```

### IAM (Current)
```nix
users.users.sasha = {
  extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
};
# wheel = sudo, libvirtd = VMs only
```

### IAM (Future with selfhostblocks)
```nix
# Service accounts with minimal permissions
users.users.vaultwarden = { isSystemUser = true; group = "vaultwarden"; };
users.users.nextcloud = { isSystemUser = true; group = "nextcloud"; };
```

---

## Troubleshooting

### Flake not seeing changes
```bash
git add -A  # Stage changes for nix to see dirty tree
```

### Module not found
```bash
nix flake check --show-trace  # Full error trace
```

### Home-manager conflicts
```bash
home-manager switch --flake .#sasha@alice -b backup
# Creates .backup files for conflicts
```
