# Skarabox Setup Guide for Alice (Option B - Partial Integration)

Based on the official Skarabox installation manual, this guide covers the remaining setup steps needed for your alice desktop system.

## Current Status

✅ **Completed:**
- Migrated `flake.nix` to flake-parts structure
- Added skarabox-related inputs
- Desktop configuration preserved (NetworkManager, auto-login, GUI)
- No reformatting required - active system untouched

❌ **Remaining:** Generate required files and configure network/hostname

---

## Phase 1: SOPS Encryption Infrastructure

Skarabox uses a dual-key encryption system where secrets are encrypted by both your personal key and the host key.

### Step 1.1: Generate Your Personal Age Key

```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

This creates your personal age encryption key. Output will show:
```
# created: 2024-01-18T10:30:00Z
# public key: age1w862ljyrvd0kg9297e55zlzjzztkvle7vu82n5tzwdxdqxnr8aqqp8x66x
AGE-SECRET-KEY-1...
```

**Save the public key** - you'll need it for `.sops.yaml`

### Step 1.2: Create SOPS Configuration File

Create `.sops.yaml` in your repository root:

```yaml
keys:
  - &alice age1w862ljyrvd0kg9297e55zlzjzztkvle7vu82n5tzwdxdqxnr8aqqp8x66x  # Your personal key
  # - &alice_host age1...  # Host key (uncomment and add when known)

creation_rules:
  - path_regex: secrets/.*
    key_groups:
      - age:
          - *alice

  # Future skarabox host secrets (uncomment when adding more hosts)
  # - path_regex: alice/secrets.yaml
  #   key_groups:
  #     - age:
  #         - *alice
  #         - *alice_host
```

### Step 1.3: Create Secrets Directory and File

```bash
mkdir -p secrets
```

Create `secrets/alice.yaml` with placeholder content:

```yaml
# Skarabox secrets for alice host
# Add credentials here as needed:

# Example:
# skarabox:
#   zfs_root_passphrase: "your-passphrase-here"
#   user_password: "your-password-here"
```

Then encrypt it:

```bash
sops secrets/alice.yaml
```

This will open an editor where you can add actual secrets. The file will be automatically encrypted with your age key.

---

## Phase 2: Host-Specific Configuration

### Step 2.1: Create Alice Host Directory Structure

```bash
mkdir -p hosts/alice/skarabox
```

### Step 2.2: Determine Network Configuration

For alice (your active desktop), decide on networking:

**Option A: Keep Current DHCP Setup**
- Simple, no IP changes needed
- Add to `hosts/alice/default.nix`:

```nix
# Network configuration for alice
networking.hostName = "alice";  # Already configured
networking.networkmanager.enable = true;  # Already configured
# Keep current DHCP setup
```

**Option B: Static IP (For Server Use)**
If alice will serve as a server, configure static IP:

```bash
# First, find current network configuration
ip addr
ip route

# Example output:
# inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic noprefixroute wlp3s0
# via 192.168.1.1 dev wlp3s0 proto dhcp metric 600
```

Then update `hosts/alice/default.nix`:

```nix
# Static IP configuration (optional, replace with your values)
networking.useDHCP = false;
networking.interfaces.eth0.ipv4.addresses = [
  {
    address = "192.168.1.100";
    prefixLength = 24;
  }
];
networking.defaultGateway = "192.168.1.1";
networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
```

### Step 2.3: Generate facter.json (Hardware Configuration)

The facter.json file contains hardware specifications that skarabox uses for disk configuration.

First, check if skarabox provides a facter binary:

```bash
# Check if available in flake
nix flake show .#

# Try to run facter if available
nix run .#get-facter -- --format json > hosts/alice/facter.json
```

If not directly available, manually create `hosts/alice/facter.json` based on your hardware:

```bash
# Get your hardware info
lsblk -d -o name,type,size,model
cpu_cores=$(nproc)
total_ram=$(free -h | awk '/^Mem:/ {print $2}')
```

Create `hosts/alice/facter.json`:

```json
{
  "hostname": "alice",
  "system": "x86_64-linux",
  "cpus": 4,
  "cpuModel": "AMD",
  "memorySize": 16000000000,
  "disks": [
    {
      "device": "/dev/nvme0n1",
      "type": "nvme",
      "size": 512110190592,
      "model": "Samsung 970 EVO",
      "serial": "S4D7NJXXX0XXXX"
    }
  ]
}
```

---

## Phase 3: SSH Keys and Host Identity

### Step 3.1: Generate Host SSH Keypair

For alice to support SSH operations (especially for skarabox deployment):

```bash
ssh-keygen -t ed25519 -f hosts/alice/ssh_key -N ""
```

This creates:
- `hosts/alice/ssh_key` (private key)
- `hosts/alice/ssh_key.pub` (public key)

### Step 3.2: Generate ZFS Host ID

Skarabox uses a unique host ID for ZFS:

```bash
# Generate a random 8-character hex string
openssl rand -hex 4
# Example output: f47ac10b

# Save to file
echo "f47ac10b" > hosts/alice/hostid
```

### Step 3.3: Create SSH Boot Key (For Future SSH Unlock)

When ready to enable SSH-based encrypted pool unlocking:

```bash
ssh-keygen -t ed25519 -f hosts/alice/host_key -N ""
```

This creates:
- `hosts/alice/host_key` (private key)
- `hosts/alice/host_key.pub` (public key)

### Step 3.4: Generate known_hosts File

```bash
# Get your alice's IP address
alice_ip=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1)

# Generate known_hosts entry
ssh-keyscan -t ed25519 $alice_ip >> hosts/alice/known_hosts 2>/dev/null

# Or if you have hostname resolution
ssh-keyscan -t ed25519 alice.local >> hosts/alice/known_hosts 2>/dev/null
```

---

## Phase 4: Update Flake Configuration

### Step 4.1: Uncomment Skarabox Host Age Key (When Ready)

Once you have the host key, extract its age equivalent:

```bash
ssh-to-age < hosts/alice/host_key.pub
# Output: age1...
```

Then update `.sops.yaml`:

```yaml
keys:
  - &alice age1w862ljyrvd0kg9297e55zlzjzztkvle7vu82n5tzwdxdqxnr8aqqp8x66x
  - &alice_host age1...  # Add this line with actual output
```

### Step 4.2: Update flake.nix with Host Details

Update the skarabox configuration in `flake.nix` (when enabling full features):

```nix
skarabox.hosts = {
  alice = {
    system = "x86_64-linux";
    nixpkgs = inputs.nixpkgs;

    # Network configuration
    ip = "192.168.1.100";  # Your alice IP
    gateway = "192.168.1.1";

    # SSH configuration
    sshPort = 2222;
    sshBootPort = 2223;

    # Host identification
    hostKeyPub = ./hosts/alice/host_key.pub;
    knownHosts = ./hosts/alice/known_hosts;

    modules = [
      inputs.sops-nix.nixosModules.default
      self.nixosModules.alice
      # Skarabox configuration (optional, for advanced features)
      # inputs.skarabox.nixosModules.default
    ];
  };
};
```

### Step 4.3: Update Host Configuration

Update `hosts/alice/default.nix` to include skarabox-aware settings:

```nix
{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
    ../../modules/boot.nix
    ../../modules/security.nix
    ../../modules/users.nix
    ../../modules/desktop.nix
    ../../modules/nix-settings.nix
  ];

  # Host identification
  networking.hostName = "alice";
  networking.hostId = "f47ac10b";  # From hostid file

  # Network configuration (choose one)
  # Option 1: DHCP (current)
  networking.networkmanager.enable = true;

  # Option 2: Static IP (for server mode)
  # networking.useDHCP = false;
  # networking.interfaces.eth0.ipv4.addresses = [{
  #   address = "192.168.1.100";
  #   prefixLength = 24;
  # }];

  # Desktop configuration
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "sasha";
  system.stateVersion = "25.11";

  # Skarabox optional configuration (when fully enabling)
  # skarabox = {
  #   hostname = "alice";
  #   username = "sasha";
  #   sshPort = 2222;
  #   sshBootPort = 2223;
  # };
}
```

---

## Phase 5: Update Sops Configuration in Host

### Step 5.1: Configure sops-nix Module

Update `hosts/alice/default.nix` to use sops:

```nix
{
  # ... existing configuration ...

  sops = {
    defaultSopsFile = ../../secrets/alice.yaml;
    age.keyFile = "/root/.config/sops/age/keys.txt";
    age.generateKey = true;

    secrets = {
      # Example: if you add secrets to secrets/alice.yaml
      # example_secret = {};
    };
  };
}
```

---

## Phase 6: Verification and Next Steps

### Step 6.1: Verify Flake Structure

```bash
nix flake show
# Should output:
# ├─ nixosConfigurations
# │  └─ alice
# └─ nixosModules
#    └─ alice
```

### Step 6.2: Verify Configuration Loads

```bash
nix flake check
# May report missing secrets (expected), but should not error on structure
```

### Step 6.3: Test Build (Optional)

```bash
# Build without secrets (will fail on secrets, which is OK)
nix build .#nixosConfigurations.alice.config.system.build.toplevel 2>&1 | grep -i error | head -20
```

---

## File Checklist

Create these files to complete the setup:

```bash
# Encryption and secrets
✓ ~/.config/sops/age/keys.txt           # Your personal age key (not in repo!)
✓ .sops.yaml                             # Encryption configuration
✓ secrets/alice.yaml                     # Encrypted secrets file

# Host-specific files
✓ hosts/alice/facter.json               # Hardware specification
✓ hosts/alice/hostid                    # ZFS host ID
✓ hosts/alice/ssh_key                   # SSH private key
✓ hosts/alice/ssh_key.pub               # SSH public key
✓ hosts/alice/host_key                  # Boot unlock private key (optional)
✓ hosts/alice/host_key.pub              # Boot unlock public key (optional)
✓ hosts/alice/known_hosts               # Known hosts for SSH
```

---

## Network Configuration Reference

### Current Setup (Keep as-is)

- Uses NetworkManager for wireless/wired networking
- Gets IP via DHCP
- Works with desktop workflow

### For Server Mode (Optional Future)

If alice becomes a server, you might want:

```bash
# Find current network interface
ip link show
# Example: wlp3s0, eth0, enp6s0

# Find current IP
ip addr show
# Example: 192.168.1.100/24

# Find gateway
ip route show default
# Example: default via 192.168.1.1

# Find nameservers
cat /etc/resolv.conf
# Example: nameserver 8.8.8.8
```

---

## Skarabox Documentation References

For detailed information, refer to:

- **Installation**: https://installer.skarabox.com/installation.html
- **All Options**: https://installer.skarabox.com/options.html
- **Architecture**: https://installer.skarabox.com/architecture.html
- **Normal Operations**: https://installer.skarabox.com/normal-operations.html
- **SelfHostBlocks SOPS**: https://shb.skarabox.com/blocks-sops.html

---

## Command Summary

Quick reference for all commands in order:

```bash
# 1. Generate age key
age-keygen -o ~/.config/sops/age/keys.txt

# 2. Create sops config
# (Edit .sops.yaml manually)

# 3. Create secrets directory and file
mkdir -p secrets
# (Create secrets/alice.yaml)
sops secrets/alice.yaml

# 4. Create host directories
mkdir -p hosts/alice/skarabox

# 5. Generate SSH keys
ssh-keygen -t ed25519 -f hosts/alice/ssh_key -N ""
ssh-keygen -t ed25519 -f hosts/alice/host_key -N ""

# 6. Generate host ID
openssl rand -hex 4 > hosts/alice/hostid

# 7. Generate known_hosts
ssh-keyscan -t ed25519 $(hostname -I | awk '{print $1}') >> hosts/alice/known_hosts 2>/dev/null

# 8. Extract host age key
ssh-to-age < hosts/alice/host_key.pub

# 9. Verify flake
nix flake show
nix flake check

# 10. Rebuild (when ready)
nixos-rebuild switch --flake .#alice
```

---

## Important Notes

1. **Keep personal age key private** - don't add `~/.config/sops/age/keys.txt` to git
2. **secrets/alice.yaml is encrypted** - safe to commit after encryption
3. **SSH keys in hosts/alice/** - consider if these should be in version control
4. **facter.json** - describes hardware, safe to commit
5. **known_hosts** - contains host keys, safe to commit

---

## Next Steps After Setup

1. Follow steps 1-6 above to generate all required files
2. Verify flake with `nix flake check`
3. When ready, rebuild: `nixos-rebuild switch --flake .#alice`
4. Alice continues to work as desktop system with skarabox infrastructure
5. Later, optionally enable skarabox-specific features by uncommenting options in flake.nix
