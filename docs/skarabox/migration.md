# Skarabox Migration Plan

## Completed

- [x] **Step 1:** flake-parts wrapping, skarabox flakeModule imported
- [x] **Step 2:** SOPS dual-key — `.sops.yaml` at repo root, secrets at `hosts/alice/secrets.yaml`
- [x] **Step 3:** `hashedPassword` moved to sops in `users.nix`, secret defined in `secrets.nix`
- [x] **Step 6:** `homeConfigurations` removed (used `nixos-rebuild`, not standalone HM)
- [x] Inputs enabled: `nixos-generators`, `nixos-anywhere`, `deploy-rs`
- [x] `nixos-facter-modules` input removed (skarabox bundles its own)

## Not Applicable to Alice

Steps 4-5 are skarabox-host specific. Alice is a desktop (`nixosConfigurations.alice`),
not a skarabox-managed server. These steps apply when adding a new server host.

- **Step 4 (host metadata):** `hostid`, `host_key.pub`, `ip`, `ssh_port`, etc. are
  consumed by `skarabox.hosts.<name>` entries, not by regular nixosConfigurations.
- **Step 5 (nixos-facter):** Replaces `hardware-configuration.nix` for skarabox hosts.
  Alice keeps its `hardware-configuration.nix`.

## Adding a Server Host

See `setup-instructions.md` for the full guide. Quick summary:

```bash
# 1. Scaffold
nix run .#gen-new-host myserver

# 2. Add to .sops.yaml
nix run .#add-sops-cfg -- -o .sops.yaml myserver $(ssh-to-age -i ./myserver/host_key.pub)

# 3. Configure
$EDITOR myserver/configuration.nix

# 4. Add to flake.nix skarabox.hosts

# 5. Boot beacon, get facter, install
nix run .#myserver-beacon-vm &          # or build ISO for real hardware
nix run .#myserver-get-facter > myserver/facter.json
git add myserver/
nix run .#myserver-install-on-beacon
```

## Lessons Learned

- `nix shell nixpkgs#ssh-to-age` fails if nix registry points to your flake.
  Use `nix develop` instead (ssh-to-age is in dev.nix).
- `sops` errors with "metadata not found" on plaintext files.
  Delete the file first, then let sops create it fresh.
- Nix flakes only see git-tracked files. Always `git add` new files
  before running `nix flake check`.
- Skarabox CLI tools expect `sops.key` at repo root (set by `skarabox.sopsKeyPath`).
  Symlink from `~/.config/sops/age/keys.txt` or set the option.
- `skarabox.flakeModules.deploy-rs` fails with zero hosts (its deploy checks
  access `flake.deploy` which has no value). Only import it when `skarabox.hosts`
  has at least one entry.
- `nixos-facter-modules` input is redundant — skarabox's `nixosModules.skarabox`
  bundles its own. Only declare it if using facter independently (e.g. for a desktop).
