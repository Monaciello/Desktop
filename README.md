# Desktop Configuration

Cross-platform Nix configuration for NixOS (`alice`) and macOS (`macbook`). Based on [nix-starter-config](https://github.com/Misterio77/nix-starter-configs).

## Architecture

For an overview of the directory structure and role of each folder/file, see `flake.nix` and the subdirectories:
- `hosts/alice/` — system-level configuration (hardware, boot, services)
- `home-manager/` — user dotfiles and user applications:
  - `modules/` (Sway, kitty, neovim, rofi, zsh modules; see files within)
  - `programs/` (git, tmux module definitions)
- `shells/` — project/dev environment shells (see example: `shells/default.nix`)
- `pkgs/` — custom package definitions
- `overlays/` — package modifications

## Design Principles

- **Layer separation:** See `flake.nix` for delineating system (nixos-rebuild), user (home-manager), and project (nix develop) layers.
- **Shell:** **zsh** + Starship are the interactive shell on both NixOS and macOS (`home-manager/modules/zsh.nix`). Optional **xonsh** tooling lives in `pkgs/xontrib-uvox` if you use xonsh separately.
- **Declarative:** Package/plugin managers are declared in Nix modules, e.g., see `home-manager/modules/neovim.nix`—no symlink or pip installs.
- **Reproducible:** Build reproducibility is established by the use of a pinned `flake.lock` (see root), ensuring hermetic builds in `/nix/store`.

### Determinism (explicit choices)

- **`nixpkgs` vs `nixpkgs-darwin`:** NixOS (`alice`) uses `nixos-unstable`; macOS (`macbook`) uses `nixpkgs-unstable` from the separate `nixpkgs-darwin` input. They can drift in package versions—**if you want lockstep parity**, point both at the same `nixpkgs` rev (trade-off: Darwin sometimes needs the Darwin-specific input for fixes).
- **`rpi-imager`:** Uses the upstream **AppImage v2.0.6** with a fixed-output hash (`pkgs/rpi-imager-appimage`). Linux-only; overlays skip it on Darwin. If imaging misbehaves on Sway, try another release and update the hash.
- **`python-backtrace`:** Upstream has **no release tags**; `rev` is pinned to git commit `a1f75c956f669a6175088693802d5392e6bd7e51` (same tree as the old `master` hash).
- **MCP servers:** Separate flake `mcp/flake.nix` (own `flake.lock`). Update it alongside the main Desktop flake when bumping `nixpkgs`, or MCP packages may drift from the rest of the workspace.
- **`pkgs.unstable` overlay:** Removed — nothing referenced it; use a normal overlay or input pin if you need a second nixpkgs fork later.
- **Homebrew (macOS):** `onActivation.autoUpdate` is **false** and `cleanup` is **true** (not `zap`) so `darwin-rebuild` does not silently refresh all casks or remove extra Homebrew state. Update casks manually when you want (`brew upgrade`).
- **Nix on macbook:** `hosts/macbook/nix.nix` matches `hosts/alice/nix.nix` for `trusted-users`, flake `nixPath`, and `channel.enable = false` (same developer ergonomics as NixOS).
- **Git `user.email`:** Set to **GitHub noreply** in `programs/git.nix` so a private address is not committed. Use a local `include` or override if you need another identity.

## Current Phase: Documentation & Validation

Focus: Clean up docs; verify the flake builds cleanly.
Validation: `nix flake check` (builds `checks.<system>.nixos-alice` on Linux and `darwin-macbook` on aarch64-darwin). For full host builds, use `nixos-rebuild build --flake …` / `darwin-rebuild build --flake …`.

## Action Items

| # | Task | Location | Notes |
|---|------|----------|-------|
| 1 | ~~Add fallback DE (xfce4)~~ | — | **Skipped.** Moving to GNOME eventually; adapt config to mimic macbook. |
| 2 | ~~Review autorandr~~ | `hosts/alice/packages.nix` | **Done.** Using `wlr-randr` / `wdisplays` / `kanshi` instead; no `autorandr` in tree. |
| 3 | Test all shells workloads | `shells/`, `home-manager/modules/zsh.nix` | Update per zsh.nix. |
| 4 | ~~nixd + statix + formatter CLIs; Neovim LSP~~ | `dev.nix`, `neovim.nix` | **Done** — `nixd`/`pyright` wired via `programs.neovim.initLua`. |
| 5 | Update Obsidian vault path | — | Iterative once NUC is up; sync to Nextcloud Obsidian vault. |
| 6 | Test image.nvim with lf | `home-manager/modules/neovim.nix` | lf integration. |
| 7 | Configure vanilla keybindings | `docs/Desktop/` | Avoid over-customization; first principles. |

**Manual follow-ups (not automated in Nix):** exercise dev **shells** (#3), set **Obsidian** vault path when NUC/Nextcloud is ready (#5), try **image.nvim** + **lf** together (#6), and adjust **keybindings** in vault docs (#7). **Darwin `flake check`** on Linux skips `aarch64-darwin` unless you use `--all-systems` with a Darwin builder.

## Roadmap

### Phase 4: Multi-Host Prep
- *Extract common configuration:* see `hosts/common/`
- *Green flake check:* See goals in `flake.nix`, use `nix flake check`

### Phase 5: Skarabox + SHB (openclaw P0–P2)
- Inputs and server host scaffolding: See `flake.nix` for adding new hosts.
- Forgejo & SHB: See `docs/Desktop/deployment/skarabox-deployment-guide.md`.

### Phase 5b: VM Isolation (openclaw P3)
- See `microvm.nix` (incoming) replacing libvirtd for VMs

### Phase 6: OpenClaw (openclaw P4–P6)
- SOPS/agent secrets: see `secrets/agent.yaml`
- Openclaw modules: See `docs/Desktop/openclaw/master-guide.md`

### Phase 7: Observability + OCI (openclaw P7–P9)
- Monitoring and observability: See `docs/Desktop/reference/`

## Bootstrap New macOS Machine

### Prerequisites

1. **Install Nix:**
   See official install instructions, or refer to the install script at [nixos.org](https://nixos.org/download.html).

2. **Enable flakes:**
   To enable flakes, edit `~/.config/nix/nix.conf` as documented in (Nix flake documentation).

3. **Install Xcode CL Tools:**
   See Apple's documentation.

4. **Clone this repository:**
   Create a `~/Projects` directory, then clone this repo into `~/Projects/Desktop` (see any standard git clone step).

### First-Time Activation

For first-time nix-darwin activation, see usage of the `nix run nix-darwin ...` command as shown in the examples and in docs (`docs/Desktop/setup/`).

Summary:
- Installs nix-darwin config
- Sets up Homebrew via nix-homebrew (see `hosts/macbook/homebrew.nix`)
- Installs GUI apps as casks (see config in `hosts/macbook/homebrew.nix`)
- Sets system defaults and sudo Touch ID (see `hosts/macbook/default.nix`)
- Sets up home-manager and user dotfiles (see `home-manager/`)

### Subsequent Rebuilds

For rebuilding, see:
- `darwin-rebuild` command as captured in the shell and in documentation (`docs/Desktop/`)
- Custom shell aliases (see `home-manager/modules/zsh.nix` for `rebuild` alias)

### What Gets Installed

**Via Nix:**
Review `hosts/macbook/default.nix` and `home-manager/modules/` for:
- Dev tools (defined under `environment.systemPackages`)
- CLI tools (see consolidated list in home-manager modules)
- Shell with prompt: see `home-manager/modules/zsh.nix` and starship config

**Via Homebrew (GUI apps):**
Check the list at `hosts/macbook/homebrew.nix`

**Dotfiles:**
Review `home-manager/modules/` for Neovim, kitty, tmux, git config, lf, ssh; see platform-aware aliases in relevant shell modules.

### Customization

1. **Change hostname:**
   Edit `networking.hostName` in `hosts/macbook/default.nix` (see full option structure in that file).

2. **Add/remove Homebrew casks:**
   Update the `casks = [ ... ]` list in `hosts/macbook/homebrew.nix`.

3. **Modify system settings:**
   Edit `system.defaults.*` fields in `hosts/macbook/default.nix`.

## Commands

- **For NixOS (`alice`):**
  - See usage in the documentation and `flake.nix` for `nixos-rebuild switch --flake ...`
  - For home-manager, review invocation in `flake.nix` and docs

- **For macOS (`macbook`):**
  - Use `darwin-rebuild switch --flake ...` as shown in the documentation

- **Cross-Platform:**
  - Dev shells: see examples in `shells/`
  - Validation/formatting: refer to `flake.nix` outputs and any formatting scripts

## Adding Packages

1. **Check if package is already defined:**
   Use grep or your favorite search tool to look for `"packageName"` in `*.nix` files.

2. **Add to correct location:**
   - System package: add in `hosts/alice/*.nix`
   - User tool: add in `home-manager/packages/*.nix`
   - Dev tool: add in `shells/default.nix`

3. **Rebuild as needed:**
   - Step through rebuild as shown in this README and referenced `nixos-rebuild`, `darwin-rebuild`, or `home-manager switch` flows.

## Adding Home-Manager Module

1. **Create new module file:**
   Add `newmodule.nix` to `home-manager/modules/`

2. **Import in module aggregator:**
   Add to the `imports` array in `home-manager/modules/all.nix`

3. **Stage and rebuild:**
   Follow documented git flow and rebuild using a `home-manager` invocation as above.

## Troubleshooting

- If changes aren't picked up, ensure you've staged/saved files and try `git add -A`.
- For module errors, invoke `nix flake check --show-trace` for debug info.
- For file conflicts, try `home-manager switch -b backup` for safe switching.
- For system recovery, see the rollback flow with `nixos-rebuild --rollback`.

## Documentation

**Most documentation has moved to `~/Projects/docs/Desktop/`.** For navigation and entry points, see `docs/README.md` in the repo.

Key example doc files:
- `docs/Desktop/wip.md` — Sprint tracker
- `docs/Desktop/migration/skarabox.md` — Skarabox migration info
- `docs/Desktop/deployment/skarabox-deployment-guide.md` — Skarabox deployment
- `docs/Desktop/setup/sops-setup.md` — SOPS encryption setup
- `docs/Desktop/openclaw/master-guide.md` — OpenClaw guides and modules
- `docs/Desktop/reference/` — Extended Nix recipes, config role matrix, shell/service alias map, etc.

Further AI and project constraints:
- `.claude/AI.md` — AI assistant guardrails
- `.claude/CLAUDE.md` — Project-specific constraints
