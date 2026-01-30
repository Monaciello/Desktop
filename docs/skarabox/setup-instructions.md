# Skarabox Integration

Guide for integrating skarabox framework. Reference: [nix-starter-configs-skarabox](https://github.com/ibizaman/nix-starter-configs-skarabox)

## Prerequisites

- Working NixOS flake
- sops-nix configured (see `sops-setup.md`)

## Host Directory Structure

Each skarabox host needs:

```
<hostname>/
├── configuration.nix  # NixOS module (NOT encrypted)
├── secrets.yaml       # Encrypted secrets
├── facter.json        # Hardware config from nixos-facter
├── hostid             # ZFS host ID (8 hex chars)
├── host_key.pub       # SSH host public key
├── ssh.pub            # User SSH public key
├── ip                 # IP address
├── ssh_port           # SSH port number
├── ssh_boot_port      # Boot SSH port for unlock
├── known_hosts        # SSH known hosts
└── system             # System type (x86_64-linux)
```

## Generate Host Files

```bash
# Host ID
openssl rand -hex 4 > hosts/alice/hostid

# SSH keys
ssh-keygen -t ed25519 -f hosts/alice/host_key -N ""
ssh-keygen -t ed25519 -f hosts/alice/ssh -N ""

# Ports
echo "2222" > hosts/alice/ssh_port
echo "2223" > hosts/alice/ssh_boot_port

# IP
echo "192.168.1.100" > hosts/alice/ip

# System
echo "x86_64-linux" > hosts/alice/system

# Hardware (run on target)
nix run github:numtide/nixos-facter -- -o hosts/alice/facter.json
```

## Flake Configuration

```nix
{
  inputs = {
    skarabox.url = "github:ibizaman/skarabox";
    # ... other inputs
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.skarabox.flakeModules.default ];

      skarabox.hosts = {
        alice = {
          system = ./hosts/alice/system;
          hostKeyPath = "./hosts/alice/host_key";
          hostKeyPub = ./hosts/alice/host_key.pub;
          ip = ./hosts/alice/ip;
          sshPrivateKeyPath = "./hosts/alice/ssh";
          sshPublicKey = ./hosts/alice/ssh.pub;
          knownHosts = ./hosts/alice/known_hosts;
          knownHostsPath = "./hosts/alice/known_hosts";
          secretsFilePath = "./hosts/alice/secrets.yaml";

          modules = [
            inputs.sops-nix.nixosModules.default
            ./hosts/alice/configuration.nix
          ];
        };
      };
    };
}
```

## Host Configuration

```nix
# hosts/alice/configuration.nix
{ lib, config, ... }:
{
  skarabox = {
    hostname = "alice";
    username = "sasha";
    hashedPasswordFile = config.sops.secrets."alice/user/hashedPassword".path;
    facter-config = ./facter.json;
    hostId = ./hostid;
    sshPort = ./ssh_port;
    sshAuthorizedKeyFile = ./ssh.pub;

    boot.sshPort = ./ssh_boot_port;

    disks.rootPool = {
      disk1 = "/dev/nvme0n1";
      reservation = "500M";
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/boot/host_key" ];
    secrets."alice/user/hashedPassword".neededForUsers = true;
  };
}
```

## Auto-Generated Commands

After configuration, skarabox provides:

```bash
nix run .#alice-unlock      # Decrypt root partition
nix run .#alice-ssh         # SSH to host
nix run .#gen-new-host NAME # Scaffold new host
```

## Verification

```bash
nix flake show
nix flake check
nix build .#nixosConfigurations.alice.config.system.build.toplevel
```

## References

- [Installation](https://installer.skarabox.com/installation.html)
- [Options](https://installer.skarabox.com/options.html)
- [SelfHostBlocks](https://shb.skarabox.com/)
