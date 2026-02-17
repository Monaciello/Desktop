# 1Password + SOPS Integration Guide

Integration pattern for managing secrets with 1Password as the source of truth and SOPS as the encrypted git storage layer.

## Architecture: The Three-Layer Approach

```
1Password (Source of Truth)
    ↓
SOPS (Encrypted Git Storage)
    ↓
NixOS Runtime (Decrypted Secrets)
```

**Why this approach?**
- **1Password**: Human-accessible secrets (passwords, API keys, SSH keys)
- **SOPS**: Machine secrets encrypted in git (database passwords, service tokens)
- **Age with 1Password**: Bridge between the two using `age-plugin-1p`

## Option 1: age-plugin-1p (Recommended)

Store your age private key in 1Password, use it to encrypt/decrypt SOPS files without exposing the key on disk.

### Setup

1. **Generate age key and store in 1Password:**
```bash
# Generate age key pair
age-keygen -o age-key.txt

# View the key
cat age-key.txt
# AGE-SECRET-KEY-1QQPQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ

# Add to 1Password:
# - Create new "Password" item in vault
# - Title: "NixOS SOPS Age Key"
# - Password field: <paste AGE-SECRET-KEY-...>
# - Copy the public key for later

# Delete the local file (key now stored in 1Password)
shred -u age-key.txt
```

2. **Configure SOPS to use age-plugin-1p:**
```yaml
# .sops.yaml
keys:
  - &alice-age age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

creation_rules:
  - path_regex: hosts/alice/secrets.yaml$
    key_groups:
      - age:
          - *alice-age
```

3. **Set up age-plugin-1p:**
```bash
# Install plugin (already in system packages)
# Configure environment
export AGE_PLUGIN_1P_ACCOUNT="<your-1password-account-id>"

# Test decryption with 1Password key
echo "test" | age -r age1xxx... | age -d -i "age-plugin-1p://vaults/Private/items/NixOS-SOPS-Age-Key"
```

4. **Encrypt/decrypt SOPS files:**
```bash
# Edit secrets (prompts for 1Password unlock)
sops hosts/alice/secrets.yaml

# Decrypt to stdout
sops -d hosts/alice/secrets.yaml
```

## Option 2: Manual Copy (Simpler, Less Secure)

Keep age key on disk, use 1Password as reference only.

### Setup

1. **Use existing age key from SSH host key:**
```nix
# Already configured in hosts/alice/secrets.nix
sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
```

2. **Store secrets in 1Password, copy to SOPS when needed:**
```bash
# Get secret from 1Password
op read "op://Private/Database-Password/password"

# Edit SOPS file and paste
sops hosts/alice/secrets.yaml

# Add entry:
# database_password: <paste-from-1password>
```

## Workflow Comparison

### Adding a New Secret

| Task | Manual (.env) | 1Password + SOPS (age-plugin-1p) |
|------|---------------|-----------------------------------|
| Store secret | `.env` file on disk | 1Password vault |
| Encrypt for NixOS | N/A (plaintext!) | `sops secrets.yaml` (auto-encrypts via 1P) |
| Deploy | `scp .env` to server | `git push` + `nixos-rebuild` |
| Access control | File permissions only | 1Password + SOPS + UNIX permissions |
| Backup | Manual `cp .env .env.bak` | Automatic (1P sync + git history) |

### Updating/Rotating a Secret

| Step | Manual (.env) | 1Password + SOPS |
|------|---------------|------------------|
| 1. Update | Edit `.env` file | Update in 1Password |
| 2. Sync | `scp` to server | `sops secrets.yaml` → paste new value |
| 3. Apply | Restart service manually | `nixos-rebuild switch` |
| 4. Verify | SSH in, check env | Service auto-reloads with new secret |

## SOPS + 1Password Hybrid Pattern

**Best practice for homelab:**

1. **Human secrets → 1Password only**
   - Personal SSH keys
   - Personal API tokens
   - Development credentials

2. **Machine secrets → SOPS (encrypted with age key from 1Password)**
   - Database passwords
   - Service API keys
   - SSL certificates

3. **Bridge: age-plugin-1p**
   - Age key stored in 1Password
   - SOPS files encrypted with that age key
   - NixOS decrypts via SSH host key OR age-plugin-1p

## Security Considerations

**age-plugin-1p advantages:**
- ✅ Private key never on disk
- ✅ 1Password MFA protects SOPS decryption
- ✅ Key rotation via 1Password

**age-plugin-1p disadvantages:**
- ❌ Requires 1Password unlock for every SOPS edit
- ❌ Cannot decrypt in automated pipelines (CI/CD)
- ❌ More complex setup

**SSH host key advantages:**
- ✅ Simple setup (key already exists)
- ✅ Works in automation
- ✅ No 1Password dependency for decryption

**SSH host key disadvantages:**
- ❌ Private key on disk (encrypted partition recommended)
- ❌ No MFA for SOPS access
- ❌ Key compromise = all secrets compromised

## Recommended Setup for Alice (Your Laptop)

Use **dual-key encryption** (both approaches):

```yaml
# .sops.yaml
keys:
  - &alice-ssh age1xxxx...  # From /etc/ssh/ssh_host_ed25519_key.pub
  - &alice-1p age1yyyy...   # From 1Password vault

creation_rules:
  - path_regex: hosts/alice/secrets.yaml$
    key_groups:
      - age:
          - *alice-ssh   # Can decrypt without 1Password
          - *alice-1p    # Can decrypt with 1Password as backup
```

**Why dual-key?**
- Primary: SSH host key (convenience, automation)
- Backup: 1Password key (recovery if host key lost)
- Security: Both keys required to be compromised for full breach

## References

- [NixOS 1Password Wiki](https://wiki.nixos.org/wiki/1Password)
- [sops-nix Documentation](https://github.com/Mic92/sops-nix)
- [age-plugin-1p GitHub](https://github.com/natrontech/sops-age-op)
- [Keeping Nix Secrets with SOPS](https://kobimedrish.com/posts/keeping_nix_secrets_with_sops_integratoin_and_applictions/)
- [Managing NixOS Secrets via SOPS](https://www.thenegation.com/posts/sops/)
