# NixOS Configuration

Declarative NixOS flake for alice workstation. Based on [nix-starter-config](https://github.com/Misterio77/nix-starter-configs).

## Architecture

```
flake.nix
├── hosts/alice/        # SYSTEM: hardware, boot, services
├── home-manager/       # USER: dotfiles, user apps
│   ├── modules/        # i3, kitty, neovim, rofi, xonsh
│   └── programs/       # git, tmux
├── shells/             # PROJECT: dev environments
├── pkgs/               # Custom packages
└── overlays/           # Package modifications
```

## Design Principles

- **Layer separation:** System (nixos-rebuild) | User (home-manager) | Project (nix develop)
- **Single shell:** Xonsh everywhere - Python superset for shell and scripts
- **Declarative:** No manual plugin managers, symlinks, or pip installs
- **Reproducible:** Pinned flake.lock -> hermetic builds -> immutable /nix/store

## Completed (2026-01-26 20:00 EST)

Phases 0-2 established a working i3 workstation with declarative configuration.

**Expected behavior:**
- i3wm launches on login with kitty terminal, rofi launcher, i3blocks status bar
- Neovim opens with lazy.nvim plugins, LSP support pending
- Xonsh shell with eza/bat aliases, rebuild/hms shortcuts
- GTK theme (Adapta-Nokto) applied system-wide
- tmux with declarative plugins (no TPM)
- devShells available via `nix develop`

## Current Phase: Documentation & Validation

Focus: Clean up docs, ensure flake builds without errors.

```bash
nix flake check
nix build .#nixosConfigurations.alice.config.system.build.vm
```

## Action Items

| # | Task | Location |
|---|------|----------|
| 1 | Add fallback DE (xfce4) | `hosts/alice/packages.nix` |
| 2 | Add autorandr | `hosts/alice/packages.nix` |
| 3 | Test uv venv + prompt | `shells/` |
| 4 | Document gup alias risks | `home-manager/modules/xonsh.nix` |
| 5 | Document webup alias | `home-manager/modules/xonsh.nix` |
| 6 | Remove unused command_output() | `home-manager/modules/xonsh.nix` |
| 7 | Add LSPs (nixd, pyright) | `home-manager/modules/neovim.nix` |
| 8 | Update Obsidian vault path | `home-manager/modules/dotfiles/init.lua` |
| 9 | Test image.nvim | manual verification |
| 10 | Configure vanilla keybindings | see `docs/keybindings.md` |

## Roadmap

### Phase 4: Multi-Host
- Extract common config to `hosts/common/`
- Setup deployment (colmena or deploy-rs)

### Phase 5: Skarabox Integration
- Import skarabox/selfhostblocks modules
- Services: Vaultwarden, Forgejo, Nextcloud
- See `docs/skarabox/`

### Phase 6: Infrastructure
- Monitoring (Prometheus/Grafana)
- Backup strategy, VPN mesh, CI/CD

## Commands

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#alice  # Rebuild system
home-manager switch --flake ~/.config/nixos#sasha@alice  # Rebuild home
nix develop .#dev                                         # Dev shell
nix flake check                                           # Validate
nix fmt                                                   # Format
```

## Adding Packages

```bash
# 1. Check if already defined
grep -r "packageName" --include="*.nix" .

# 2. Add to correct location
# System service -> hosts/alice/*.nix
# User tool -> home-manager/packages/*.nix
# Dev tool -> shells/default.nix

# 3. Rebuild
sudo nixos-rebuild switch --flake .#alice
```

## Adding Home-Manager Module

```bash
# 1. Create module
nvim home-manager/modules/newmodule.nix

# 2. Import in home-manager/modules/all.nix
imports = [ ./newmodule.nix ];

# 3. Stage and rebuild
git add home-manager/modules/newmodule.nix
home-manager switch --flake .#sasha@alice
```

## Troubleshooting

```bash
git add -A                              # Flake not seeing changes
nix flake check --show-trace            # Module errors
home-manager switch -b backup           # File conflicts
sudo nixos-rebuild switch --rollback    # System recovery
```

## Documentation

- `docs/keybindings.md` - i3, tmux, neovim keybindings
- `docs/skarabox/sops-setup.md` - Secrets management
- `docs/skarabox/setup-instructions.md` - Skarabox integration
- `.claude/AI.md` - AI assistant guardrails
- `.claude/CLAUDE.md` - Project-specific constraints
