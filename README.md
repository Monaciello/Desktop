# NixOS Configuration

Declarative NixOS flake for alice workstation. Based on [nix-starter-config](https://github.com/Misterio77/nix-starter-configs).

## Architecture

```
flake.nix
├── hosts/alice/        # SYSTEM: hardware, boot, services
├── home-manager/       # USER: dotfiles, user apps
│   ├── modules/        # i3, kitty, neovim, rofi, zsh
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
| 4 | ~~Document gup alias risks~~ | migrated to zsh.nix |
| 5 | ~~Document webup alias~~ | migrated to zsh.nix (localhost-only) |
| 6 | ~~Remove unused command_output()~~ | removed with xonsh migration |
| 7 | Add LSPs (nixd, pyright) | `home-manager/modules/neovim.nix` |
| 8 | Update Obsidian vault path | `home-manager/modules/dotfiles/init.lua` |
| 9 | Test image.nvim | manual verification |
| 10 | Configure vanilla keybindings | see `docs/keybindings.md` |

## Roadmap

### Phase 4: Multi-Host Prep
- Extract common config to `hosts/common/`
- Re-add deploy-rs input, `nix flake check` green

### Phase 5: Skarabox + SHB (openclaw P0–P2)
- Add skarabox + selfhostblocks inputs
- Scaffold first server host (`nix run .#gen-new-host`)
- Forgejo via `shb.forgejo` (git remote for rollback)
- Tailscale firewall hardened, Nginx + Authelia SSO
- See `docs/deployment/skarabox-deployment-guide.md`

### Phase 5b: VM Isolation (openclaw P3)
- microvm.nix replaces libvirtd
- agent-gateway VM declared in flake

### Phase 6: OpenClaw (openclaw P4–P6)
- SOPS agent secrets (`secrets/agent.yaml`)
- Scout-DJ openclaw-nix module
- Ollama local inference
- See `docs/openclaw/master-guide.md`

### Phase 7: Observability + OCI (openclaw P7–P9)
- Prometheus/Grafana/Loki via SHB
- OCI ARM companion host
- Security hardening sweep

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

```
docs/
├── wip.md                                    # Sprint tracker
├── migration/
│   └── skarabox.md                           # Skarabox migration status
├── deployment/
│   ├── skarabox-deployment-guide.md          # Vol 3: Skarabox + SHB reference
│   └── skarabox-setup-instructions.md        # Adding a server host
├── setup/
│   ├── sops-setup.md                         # SOPS age encryption setup
│   ├── 1password-sops-integration.md         # 1Password + SOPS
│   ├── 1password-quick-reference.md          # 1Password quick ref
│   └── cursor-packaging-guide.md             # Cursor packaging
├── openclaw/
│   └── master-guide.md                       # OpenClaw × NixOS × Skarabox P0–P9 guide
└── reference/
    ├── nix-types-networking-reference.md     # Vol 1: Nix types + networking
    ├── nix-types-vol2-extended-recipes.md    # Vol 2: Extended recipes
    └── aliases-and-services.md               # Shell aliases and service map
```

- `.claude/AI.md` - AI assistant guardrails
- `.claude/CLAUDE.md` - Project-specific constraints
