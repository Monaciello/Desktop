# SOPS-Nix Setup

Secrets management using sops-nix with age encryption.

## Skarabox Dual-Key Pattern

Skarabox uses TWO keys per host:
- **Host key:** Derived from SSH host key at `/boot/host_key`
- **Main key:** Your personal age key

Both keys can decrypt secrets, enabling:
- Local decryption with personal key
- System decryption with host key at boot

## Setup Steps

### 1. Generate Personal Age Key

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Get public key
age-keygen -y ~/.config/sops/age/keys.txt
# Output: age1<your-public-key>
```

### 2. Generate Host SSH Key

```bash
ssh-keygen -t ed25519 -f hosts/alice/host_key -N ""

# Convert to age public key
nix shell nixpkgs#ssh-to-age -c ssh-to-age < hosts/alice/host_key.pub
# Output: age1<host-public-key>
```

### 3. Create .sops.yaml

```yaml
keys:
  - &alice age1<host-public-key>
  - &main age1<your-personal-key>

creation_rules:
  - path_regex: hosts/alice/secrets.yaml
    key_groups:
      - age:
          - *alice
          - *main
```

### 4. Create Secrets File

```bash
# Create and encrypt
sops hosts/alice/secrets.yaml
```

Example structure:
```yaml
alice:
  user:
    hashedPassword: "$6$rounds=..."
  disks:
    rootPassphrase: "your-zfs-passphrase"
```

### 5. Configure NixOS Module

```nix
# hosts/alice/default.nix
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/boot/host_key" ];

    secrets."alice/user/hashedPassword" = {
      neededForUsers = true;
    };
  };

  users.users.sasha = {
    hashedPasswordFile = config.sops.secrets."alice/user/hashedPassword".path;
  };
}
```

### 6. Deploy Host Key

Copy `host_key` to `/boot/` on target system (done during nixos-anywhere install).

## Key Points

- Config files reference secrets via `config.sops.secrets."path".path`
- Config files are NOT encrypted - only `secrets.yaml` is
- Secrets decrypt at activation to `/run/secrets/` (tmpfs)
- Host key lives at `/boot/host_key` for boot-time decryption
- Personal key stays at `~/.config/sops/age/keys.txt`

## Password Generation

```bash
# Generate and hash
password=$(openssl rand -base64 32)
echo "$password" | mkpasswd -s
# Store hash in secrets.yaml
```

## Editing Secrets

```bash
# Edit existing encrypted file
sops hosts/alice/secrets.yaml

# Re-encrypt with new keys after .sops.yaml changes
sops updatekeys hosts/alice/secrets.yaml
```
