# SOPS-Nix Setup

Secrets management using sops-nix with age encryption.

## Dual-Key Pattern

Two keys per host — both can decrypt secrets:
- **Host key:** SSH host key (alice: `/etc/ssh/ssh_host_ed25519_key`, skarabox hosts: `/boot/host_key`)
- **Main key:** Personal age key at `~/.config/sops/age/keys.txt`

## Setup Steps

### 1. Personal age key

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Get public key
age-keygen -y ~/.config/sops/age/keys.txt
```

### 2. Derive host age key from SSH host key

```bash
# Use nix develop (not nix shell nixpkgs#ssh-to-age — that fails
# if nix registry points to your flake instead of upstream nixpkgs)
nix develop
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

### 3. Create .sops.yaml at repo root

```yaml
keys:
  - &alice age1<host-age-key-from-step-2>
  - &main age1<personal-key-from-step-1>

creation_rules:
  - path_regex: hosts/alice/secrets\.yaml$
    key_groups:
      - age:
          - *alice
          - *main
```

### 4. Create encrypted secrets file

```bash
# IMPORTANT: delete any existing plaintext placeholder first
rm hosts/alice/secrets.yaml

# sops creates a fresh encrypted file (opens $EDITOR)
sops hosts/alice/secrets.yaml
```

Content to enter:
```yaml
user-password: "$6$rounds=..."
```

After saving, the file will be encrypted with sops metadata.

**Gotcha:** If the file already exists as plaintext, `sops` will error
with `sops metadata not found`. Always delete first and let sops create it.

### 5. NixOS module config

```nix
# hosts/alice/secrets.nix
{ ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      "user-password" = { neededForUsers = true; };
    };
  };
}
```

```nix
# hosts/alice/users.nix — reference the secret
users.users.sasha = {
  hashedPasswordFile = config.sops.secrets."user-password".path;
};
```

### 6. Git-track the encrypted file

Nix flakes only see git-tracked files:
```bash
git add hosts/alice/secrets.yaml .sops.yaml
nix flake check
```

## Key Points

- `.sops.yaml` lives at **repo root** (skarabox CLI tools expect it there)
- Config files reference secrets via `config.sops.secrets."name".path`
- Config files are NOT encrypted — only `secrets.yaml` is
- Secrets decrypt at activation to `/run/secrets/` (tmpfs)
- Skarabox CLI tools use `sops.key` by default (`skarabox.sopsKeyPath`)
- For desktop hosts using system SSH key, set `age.sshKeyPaths` accordingly

## Editing Secrets

```bash
sops hosts/alice/secrets.yaml

# Re-encrypt after .sops.yaml key changes
sops updatekeys hosts/alice/secrets.yaml
```
