# 1Password Quick Reference

Quick commands and configuration for 1Password on NixOS.

## Optional Integrations

**Note:** These packages are available but not currently installed:

1. **VSCode/VSCodium/Cursor Extension**: `vscode-extensions.1Password.op-vscode`
   - Access 1Password secrets directly in the editor
   - Can add to `vscodium.nix` or `cursor.nix` extensions list
   - Usage: Reference secrets with `op://<vault>/<item>/<field>` syntax

2. **Terraform Provider**: `terraform-providers.1password_onepassword`
   - Manage 1Password resources via Infrastructure as Code
   - Useful for deploying infrastructure with Terraform
   - Can read secrets from 1Password in Terraform configs

To add VSCode extension, edit `home-manager/packages/vscodium.nix` or `cursor.nix`:
```nix
extensions = with pkgs.vscode-extensions; [
  # ... other extensions
  1Password.op-vscode
];
```

## Current Configuration

**Location:** `hosts/alice/1password.nix`

**Enabled:**
- ✅ 1Password GUI (stable v8.11.18)
- ✅ 1Password CLI (`op` command v2.32.0)
- ✅ age-plugin-1p (for SOPS integration)
- ✅ Polkit integration (user: sasha)
- ✅ Browser integration (automatic for Firefox/Chrome/Brave)

## Common Commands

### 1Password CLI

```bash
# Sign in to 1Password account
op signin

# List vaults
op vault list

# List items in a vault
op item list --vault Private

# Get password from item
op item get "GitHub Token" --fields password

# Read secret reference (for scripts)
op read "op://Private/GitHub-Token/password"

# Create new item
op item create --category=login --title="New Service" \
  --vault=Private password="secret123"
```

### SOPS with 1Password

```bash
# Edit encrypted secrets file
sops hosts/alice/secrets.yaml

# Decrypt to stdout
sops -d hosts/alice/secrets.yaml

# Rotate keys (after adding new age key)
sops updatekeys hosts/alice/secrets.yaml
```

### SSH Agent Integration

After enabling in 1Password settings GUI:

```bash
# Test SSH agent connection
ssh-add -L

# SSH will automatically use 1Password for key access
ssh user@host

# Git commits will use 1Password-stored SSH keys
git commit -S -m "Signed commit"
```

## Adding SSH/Git Integration to Home Manager

Add to `home-manager/modules/` (create new file or add to existing):

```nix
# home-manager/modules/1password-integration.nix
{ pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      # Use 1Password SSH agent
      Host *
        IdentityAgent ~/.1password/agent.sock
    '';
  };

  programs.git = {
    enable = true;
    extraConfig = {
      # Use SSH format for commit signing
      gpg.format = "ssh";
      gpg."ssh".program = "${pkgs._1password-gui}/bin/op-ssh-sign";
      # Your signing key (stored in 1Password)
      user.signingkey = "ssh-ed25519 AAAA...";
    };
    # Auto-sign all commits
    signing.signByDefault = true;
  };
}
```

Then import in `home-manager/modules/all.nix`:
```nix
imports = [
  # ... other imports
  ./1password-integration.nix
];
```

## Browser Extension Setup

### Automatic (Firefox, Chrome, Brave)
No configuration needed - works automatically after installing 1Password.

### Manual (Vivaldi, Arc, other Chromium browsers)

Edit `hosts/alice/1password.nix`:
```nix
environment.etc."1password/custom_allowed_browsers" = {
  text = ''
    vivaldi-bin
    arc-browser
  '';
  mode = "0755";
};
```

## Polkit Agent (Required for Biometric Unlock)

If using i3 (non-GNOME/KDE), add to `home-manager/modules/i3.nix`:

```nix
# Start polkit agent for 1Password biometric unlock
exec --no-startup-id ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
```

Or via systemd user service in home-manager:
```nix
systemd.user.services.polkit-gnome = {
  Unit = {
    Description = "PolicyKit Authentication Agent";
    After = [ "graphical-session.target" ];
  };
  Service = {
    Type = "simple";
    ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    Restart = "on-failure";
  };
  Install.WantedBy = [ "graphical-session.target" ];
};
```

## Testing After Rebuild

```bash
# Rebuild and switch
sudo nixos-rebuild switch --flake .#alice

# Verify 1Password packages
which op
which 1password

# Test age-plugin-1p
age-plugin-1p --help

# Open 1Password GUI
1password &

# Sign in with CLI
op signin
```

## Next Steps

1. **Install:** `sudo nixos-rebuild switch --flake .#alice`
2. **Launch:** Start 1Password GUI and sign in
3. **Enable SSH Agent:** Settings → Developer → SSH Agent (toggle on)
4. **Add SSH Keys:** Import or generate SSH keys in 1Password
5. **Test SSH:** `ssh-add -L` should show your keys
6. **Configure Browser:** Install extension from 1Password settings

## Resources

- System config: `hosts/alice/1password.nix`
- Integration guide: `docs/1password-sops-integration.md`
- NixOS Wiki: https://wiki.nixos.org/wiki/1Password
- 1Password CLI docs: https://developer.1password.com/docs/cli
