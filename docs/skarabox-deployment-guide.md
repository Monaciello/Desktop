# Skarabox Deployment Guide

Skarabox + SelfHostBlocks

Homelab Deployment Guide

Volume 3: From Linux Pipelines to Declarative Self-Hosting

Skarabox Host Schema • SHB Blocks & Contracts • VLAN Topology • Service Selection • Privacy Architecture

◆ How This Document Connects to Volumes 1 & 2

Vol 1: Nix option types → how to declare typed infrastructure

Vol 2: Extended recipes → DNS, backups, certs, secrets, diagnostics

Vol 3 (this): Skarabox + SHB → how to DEPLOY it all as real hosts

The typed modules from Vol 1-2 become the CUSTOM LAYER that sits

alongside SHB's pre-built blocks and services. Skarabox provides

the HOST LIFECYCLE: install, deploy, unlock, recover.

The Perplexity schema guide provides the HOST DATA MODEL.

Think of the repo as a model of hosts + roles + networks, not just configs. You change only Nix options and modules; everything else (ISOs, VM scripts, SSH wrappers, service configs) is generated.

Section 1: The Three-Layer Architecture

Your homelab has three layers. Each layer owns a specific concern, has its own interface, and its own tool. Mixing layers creates confusion. Separating them creates replaceability.

◆ Layer 1: Skarabox — Host Lifecycle

Owns: disk layout (ZFS + disko), encryption, boot, SSH keys,

      SOPS secret paths, beacon ISO, nixos-anywhere install,

      remote unlock, deploy-rs deployment, system facts

Interface: skarabox.hosts.<name>.{ip, system, modules, secrets}

Tool: nix run .#<host>-{ssh,beacon,install-on-beacon,unlock}

Scope: per-physical-machine (Pi, NUC, spare laptop)

▸ Layer 2: SelfHostBlocks — Service & Block Composition

Owns: reverse proxy (Nginx), SSL certs, auth (Authelia + LLDAP),

      backups (Restic/Borg), monitoring (Grafana/Prometheus/Loki),

      database (PostgreSQL), secrets (SOPS block), VPN, ZFS datasets

Interface: shb.<block>.* and shb.<service>.*

Tool: nixos-rebuild / deploy-rs (same as Layer 1 deploy)

Scope: per-service-stack (what runs on a host)

✓ Layer 3: Custom Modules (Vol 1-2) — Your Extensions

Owns: VLAN topology, firewall policy, custom monitoring collectors,

      Monero node config, privacy-specific networking, homelab.* opts

Interface: homelab.<module>.* (typed options from Vol 1-2)

Tool: same deploy pipeline, validated at nixos-rebuild time

Scope: things SHB doesn't cover that YOUR homelab needs

# How they compose in a single host's module list:

skarabox.hosts.nuc = {                  # Layer 1

  ip = "10.30.0.1";

  system = "x86_64-linux";

  modules = [

    selfhostblocks.nixosModules.default   # Layer 2

    ../../modules/roles/core-services.nix  # Layer 3

    ./configuration.nix                    # Host-specific

  ];

};

Section 2: Skarabox Host Schema — The Data Model

Each skarabox.hosts.<name> entry is a complete declaration of one physical or virtual machine. The schema has four concerns: connectivity, secrets, system identity, and configuration. This is the data model that drives ALL generated tooling.

Concern

Option Path

Type

Purpose

System

system

str / path

Architecture: x86_64-linux, aarch64-linux

System

nixpkgs

optional override

Pin nixpkgs per host if needed

Connect

ip

str

Host IP for SSH, deploy-rs, unlock

Connect

sshPort

port (default 2222)

SSH port for running system

Connect

sshBootPort

port (default 2223)

SSH port for beacon/initrd

Connect

sshPrivateKeyPath

nullOr path

SSH key for admin connection

Keys

hostKeyPath

path

Host SSH private key (SOPS encrypted)

Keys

hostKeyPub

str

Host SSH public key (for known_hosts)

Keys

knownHostsPath

path

Generated known_hosts file location

Secrets

secretsFilePath

path

SOPS YAML file for this host

Secrets

secretsRootPassphrasePath

str

Key in SOPS YAML for root ZFS passphrase

Secrets

secretsDataPassphrasePath

nullOr str

Key for data pool passphrase (if 2-pool)

Secrets

extraSecretsPassphrasesPath

attrsOf str

Additional named passphrases

Config

modules

listOf module

NixOS modules for production system

Config

extraBeaconModules

listOf module

Extra modules for install ISO only

◆ Visual: Host Schema Tree

skarabox.hosts.<name>

├─ System: { system, nixpkgs }

├─ Connectivity

│  ├─ ip, sshPort, sshBootPort

│  └─ sshPrivateKeyPath (nullOr = optional)

├─ Keys

│  ├─ hostKeyPath / hostKeyPub

│  └─ knownHostsPath / knownHosts

├─ Secrets

│  ├─ secretsFilePath           (the SOPS YAML)

│  ├─ secretsRootPassphrasePath  (ZFS root decrypt key)

│  ├─ secretsDataPassphrasePath  (ZFS data decrypt key)

│  └─ extraSecretsPassphrasesPath (attrsOf: name → path)

└─ Config

   ├─ modules             (production NixOS modules)

   └─ extraBeaconModules  (install ISO modules only)

This schema encodes the complete identity of a machine. When Skarabox evaluates the flake, it generates a NixOS system definition AND a set of operational CLI tools from this schema. Nothing is manual.

Section 3: Generated Tools Per Host

From each host's schema, Skarabox generates CLI commands as Nix packages. These are the operational verbs for your entire homelab lifecycle. You never write these scripts; you adjust the schema and they update.

Command

Phase

What It Does

Linux Foundation

<host>-beacon

Provision

Build bootable install ISO for this host

NixOS ISO gen, disko disk format

<host>-beacon-vm

Provision

Boot ISO in QEMU VM for testing

qemu-system, virtual disk images

<host>-install-on-beacon

Install

nixos-anywhere over SSH to beacon

SSH + nix copy closure + activate

<host>-unlock

Boot

Decrypt root+data ZFS pools via SSH

SSH into initrd, zfs load-key

<host>-ssh

Operate

SSH into running system as admin

SSH with host key from schema

<host>-boot-ssh

Operate

SSH into beacon/boot environment

SSH as root to initrd/beacon

<host>-get-facter

Diagnose

Collect hardware facts via SSH

nixos-facter, system profiling

<host>-gen-knownhosts-file

Keys

Generate known_hosts from hostKeyPub

ssh-keyscan equivalent

deploy-rs / colmena

Deploy

Push config changes to all hosts

Nix build + copy + switch-to-config

sops <secrets.yaml>

Secrets

Edit encrypted secrets for a host

age/GPG encryption, YAML structure

◆ Lifecycle Flow: From Bare Metal to Running Services

PROVISION                 INSTALL              BOOT

┌─────────┐  flash   ┌────────┐  reboot  ┌─────────┐

│ beacon  │ ────> │ USB    │ ─────> │ initrd  │

│ ISO     │         │ boot   │         │ SSH     │

└─────────┘         └────────┘         └───┬─────┘

    │                    │                    │

  <host>-beacon     <host>-install       <host>-unlock

                    -on-beacon                 │

                                               │

OPERATE                 DEPLOY               ▼

┌─────────┐  push    ┌────────┐        ┌─────────┐

│ running │ <──── │ deploy │        │ ZFS     │

│ system  │         │ -rs    │        │ mounted │

└─────────┘         └────────┘        └─────────┘

  <host>-ssh        nix run .#deploy-rs

Beacon vs Real System: The beacon is a temporary, minimal NixOS used only for bootstrapping. It configures networking (DHCP or static from host schema), enables SSH, and exposes the target disks. After install, the beacon is never used again unless recovery is needed. The real system is the full declaration from your modules.

Section 4: Host Types — Roles Mapped to Hardware

Instead of configuring each machine ad-hoc, define host types (roles). Each type determines which SHB blocks, SHB services, and custom modules it needs. Your hardware defines four natural host types.

Host Type

Hardware

VLAN(s)

SHB Blocks

SHB Services

Custom Modules

router

Pi (dedicated)

ALL (trunked)

Nginx, SSL, VPN, Tinyproxy

(none—forwards only)

VLAN topo, firewall, boundary monitor

core-services

NUC (x86_64)

mgmt + private

Monitoring, SOPS, SSL, Nginx, PostgreSQL, Authelia, LLDAP, Restic

Vaultwarden, Forgejo, Nextcloud, Open WebUI

Custom collectors, logging, DNS

node

Pi / laptop

public + mgmt

SOPS, Restic

(Monero, custom daemons)

Monero config, reachability probes

workstation

daily driver

private + mgmt

(client only)

(accesses via browser)

diagnostics toolkit (endpoint role)

Role Module: router.nix

The router is the only host that sees all VLANs. It enforces trust boundaries between zones. Skarabox manages its disk and boot; your custom VLAN module defines interfaces and firewall; SHB's VPN/Tinyproxy blocks can handle privacy routing.

# modules/roles/router.nix

{ config, lib, ... }: {

  imports = [

    ../networking/vlans.nix

    ../monitoring/default.nix

    ../diagnostics/default.nix

    ../dns/default.nix

  ];

  homelab.networking = {

    enable = true;

    vlans = {

      mgmt    = { id = 10; range = "10.10"; role = "management"; };

      public  = { id = 20; range = "10.20"; role = "public"; };

      private = { id = 30; range = "10.30"; role = "private"; };

    };

  };

  homelab.monitoring = {

    enable = true;

    interfaces = [ "eth0" "vlan10" "vlan20" "vlan30" ];

    boundary = {

      enable = true;

      sourceVlan = "vlan20"; foreignRange = "10.30";

    };

  };

  homelab.dns = {

    enable = true; listenAddress = "0.0.0.0"; port = 53;

    upstreams = [

      { name = "cloudflare"; address = "1.1.1.1";

        tls = true; port = 853; }

      { name = "quad9"; address = "9.9.9.9";

        tls = true; port = 853; }

    ];

    localRecords = {

      "nuc.lan"         = { type = "A"; value = "10.30.0.1"; };

      "grafana.lan"     = { type = "CNAME"; value = "nuc.lan"; };

      "vault.lan"       = { type = "CNAME"; value = "nuc.lan"; };

      "pi-monero.lan"   = { type = "A"; value = "10.20.0.2"; };

    };

  };

  homelab.diagnostics.role = "router";

}

Role Module: core-services.nix

The NUC runs all SHB services. SHB's unified interface means Vaultwarden, Forgejo, and Nextcloud share the same auth stack, backup provider, and monitoring dashboard. Your custom modules add collectors and privacy networking.

# modules/roles/core-services.nix

{ config, lib, ... }: {

  imports = [

    ../monitoring/default.nix

    ../logging/default.nix

    ../diagnostics/default.nix

  ];

  # ── SHB Blocks (Layer 2) ──

  shb.ssl.certs.letsencrypt."example.com" = {

    domain = "example.com";

  };

  shb.monitoring = {

    enable = true;

    grafanaPort = 3000;

    prometheusPort = 9090;

    lokiPort = 3100;

  };

  shb.lldap = {

    enable = true;

    domain = "example.com"; subdomain = "ldap";

  };

  shb.authelia = {

    enable = true;

    domain = "example.com"; subdomain = "auth";

  };

  # ── SHB Services (unified interface) ──

  shb.vaultwarden = {

    enable = true;

    subdomain = "vault"; domain = "example.com";

    ssl = config.shb.certs.certs.letsencrypt."example.com";

  };

  shb.forgejo = {

    enable = true;

    subdomain = "git"; domain = "example.com";

    ssl = config.shb.certs.certs.letsencrypt."example.com";

  };

  # ── Custom Layer (Vol 1-2) ──

  homelab.monitoring = {

    enable = true; metricsPort = 9100;

    targets = [

      { name = "router"; address = "10.10.0.1"; port = null; }

      { name = "pi-monero"; address = "10.20.0.2"; port = 18081; }

    ];

  };

  homelab.logging = {

    maxDiskPercent = 75; journalMaxSize = "500M";

  };

  homelab.diagnostics.role = "monitor";

}

Role Module: node.nix (Monero / privacy services)

# modules/roles/node.nix

{ config, lib, ... }: {

  imports = [

    ../monitoring/default.nix

    ../diagnostics/default.nix

  ];

  # SHB Block: backup chain data via contract

  shb.restic.instances."monero-chain" = {

    request.sourceDirectories = [ "/mnt/data/monero" ];

    settings = {

      repository.path = "sftp:nuc:/mnt/backups/monero";

      timerConfig.OnCalendar = "*-*-* 03:00:00";

    };

  };

  homelab.monitoring = {

    enable = true; interfaces = [ "eth0" ];

  };

  homelab.diagnostics.role = "endpoint";

}

Section 5: VLAN Zones, Trust Boundaries, and Firewall Policy

VLANs are the implementation of logical trust zones. Design zones first (what should be isolated from what), then map to VLAN IDs and CIDRs. Nix modules encode both topology and policy.

◆ Zone → VLAN → Policy Design Flow

STEP 1: Define trust zones (logical, hardware-independent)

  MGMT (admin traffic, SSH, metrics)

  PUBLIC (internet-facing services: Monero p2p, VPN)

  PRIVATE (internal services: Vaultwarden, Grafana, Forgejo)

STEP 2: Assign VLAN IDs + CIDRs

  MGMT    → VLAN 10, 10.10.0.0/24

  PUBLIC  → VLAN 20, 10.20.0.0/24

  PRIVATE → VLAN 30, 10.30.0.0/24

STEP 3: Write firewall rules per interface (your custom module)

  PRIVATE → PRIVATE: allowed (service-to-service)

  PRIVATE → PUBLIC:  blocked (no lateral movement)

  PUBLIC  → PRIVATE: blocked (trust boundary)

  MGMT    → ALL:     allowed (admin access)

  ALL     → MGMT:    SSH only (controlled entry point)

Zone

VLAN

CIDR

Hosts

Allowed Inbound

Allowed Outbound

MGMT

10

10.10.0.0/24

router .1

SSH from PRIVATE

ALL (admin)

PUBLIC

20

10.20.0.0/24

pi-monero .2, pi-vpn .3

Monero p2p (18080)

Internet, MGMT (metrics)

PRIVATE

30

10.30.0.0/24

nuc .1, workstations

HTTP/S from self, MGMT

Internet via router

The firewall rules come from your custom networking module (Vol 1 types), not from SHB. SHB only opens ports on localhost; your module controls which VLANs reach those ports:

# In your custom firewall (homelab.networking implementation)

networking.firewall.interfaces = {

  vlan30 = { allowedTCPPorts = [ 443 80 ]; };   # Nginx

  vlan20 = { allowedTCPPorts = [ 18080 ]; };    # Monero p2p

  vlan10 = { allowedTCPPorts = [

    config.skarabox.sshPort  # Skarabox-managed SSH

    9100  # Custom Prometheus collector

    9090  # SHB Prometheus

    3000  # SHB Grafana

  ]; };

};

Section 6: SHB Blocks ↔ Custom Recipes Decision Matrix

SHB provides pre-built blocks for common concerns. For each, the table shows what it replaces from Vol 1-2, what it adds, and when your custom module is still needed.

SHB Block

Replaces

What SHB Adds

Still Use Custom When

shb.monitoring

Vol2 R4 Logging

Grafana + Prom + Loki + auto dashboards for ALL SHB services

VLAN metrics, Monero exporters, custom bash collectors

shb.sops

Vol2 R7 Secrets

Contract-based: request/result pattern, auto-restart units

Only if you avoid SHB entirely

shb.restic

Vol2 R2 Backups

Contract-backed per-service backup + restore scripts

Rsync to non-Restic targets

shb.ssl

Vol2 R5 Certs

Let's Encrypt + self-signed via SSL contract

Internal CAs, Tor .onion certs

shb.nginx

Custom proxy

Auto-configured per-service reverse proxy + SSL

Raw TCP, non-HTTP services

shb.authelia

Custom auth

SSO + MFA for all SHB services, LDAP backend

Non-web-proxied services

shb.postgresql

Custom DB

Per-service DB with backup contract integration

SQLite-only or embedded DBs

shb.vpn

(new)

VPN tunneling for services needing privacy routing

WireGuard site-to-site (your custom)

(none)

Vol2 R1 DNS

No SHB DNS block exists

ALWAYS use custom DNS module

(none)

Vol2 R3 Cron

No SHB scheduler block

ALWAYS use custom timer module

(none)

Vol1 VLAN/FW

SHB doesn't manage topology

ALWAYS use custom networking module

(none)

Vol2 R6 Diag

SHB doesn't deploy diag tools

ALWAYS use custom diagnostics module

✓ The Decision Rule

SHB block exists for this concern?

  YES + using SHB services → Use the SHB block

  YES + custom service     → Use the SHB block via its contract

  NO                       → Use your custom module (Vol 1-2)

Custom modules ALWAYS needed for: VLAN topology, firewall,

Monero daemon, DNS resolver, diagnostic toolkit, privacy routing

Section 7: SHB Contracts — The Typed Decoupling Pattern

Contracts are the same principle as our typed option interfaces from Vol 1, formalized as a request/result protocol. A contract decouples the REQUESTER (module that needs something) from the PROVIDER (module that implements it). The contract defines the typed interface between them.

◆ Vol 1 Types vs SHB Contracts: Same Principle, Different Scale

Our Vol 1:  types.submodule { port; path; mode; }

            → validates at build time, prevents bad interpolation

SHB:        contract.secret { request = {owner, mode}; result = {path}; }

            → requester declares WHAT it needs

            → provider declares WHERE it delivers

            → neither knows the other's implementation

Result: swap Restic for Borg, or SOPS for Vault, without

        touching any service module. Same contract, new provider.

Contract

Requester Declares

Provider Returns

Current Providers

secret

owner, group, mode, restartUnits

path (decrypted file)

SOPS (shb.sops)

ssl

domain, altNames

certPath, keyPath, systemdService

Let's Encrypt, self-signed

backup

sourceDirectories

restoreScript, timerConfig

Restic, Borg (borgbackup)

databaseBackup

database type + name

restoreScript

Restic

Here's how your custom Monero module uses the secret contract alongside SHB services that also use it. Both share the same SOPS provider, neither knows about the other:

# Your custom module: request a secret via contract

shb.sops.secret."monero/rpc_password".request =

  config.homelab.monero.rpcPassword.request;

homelab.monero.rpcPassword.result =

  config.shb.sops.secret."monero/rpc_password".result;

# SHB's Vaultwarden does the same thing internally:

shb.sops.secret."vaultwarden/admin_token".request =

  config.shb.vaultwarden.adminToken.request;

# Both modules read secrets at: *.result.path

# Neither knows SOPS exists. Fully decoupled.

Section 8: Service Selection for Privacy-Focused Homelab

SHB offers 12 services. Not all are relevant to a privacy-focused homelab. Selection prioritizes data sovereignty, minimal attack surface, and web3/privacy alignment.

Tier

Service

Why It Matters

SHB Blocks Used

Host

T1 Essential

Vaultwarden

Password sovereignty, zero-trust creds

ALL core blocks

NUC

T1 Essential

Forgejo

Git sovereignty, CI runner, private repos

ALL core blocks

NUC

T2 High Value

Nextcloud

File sovereignty, CalDAV, document editing

ALL core blocks

NUC

T2 High Value

Open WebUI

Private LLM, local AI, no cloud dependency

Nginx, SSL, SOPS, Auth, Monitoring

NUC

T3 When Ready

Home-Assistant

IoT control without cloud vendor lock-in

Nginx, SSL, SOPS, Restic, Monitoring

Pi

T3 When Ready

Jellyfin

Media streaming, no subscriptions needed

Nginx, SSL, SOPS, Restic, Auth, LLDAP

NUC

T3 When Ready

*Arr stack

Media automation (Sonarr/Radarr/etc)

Nginx, SSL, VPN, Monitoring

NUC

Custom

Monero node

Privacy-preserving crypto (not SHB svc)

SOPS + Restic via contract

Pi

Custom

VPN gateway

Privacy routing for entire VLAN

VPN block + Tinyproxy block

Router/Pi

⚠ Block Deployment Order (dependencies flow downward)

1. SOPS secrets    ─ all hosts depend on decrypted secrets

2. SSL certs       ─ Nginx needs certs before binding 443

3. LLDAP + Authelia ─ auth stack required by all services

4. PostgreSQL      ─ Vaultwarden, Forgejo, Nextcloud need DBs

5. Monitoring      ─ Grafana/Prometheus/Loki observe everything

6. Services        ─ Vaultwarden → Forgejo → Nextcloud → ...

Deploy all to one host (NUC) first. Skarabox's deploy-rs handles

systemd unit ordering. The SHB module system handles inter-service.

Section 9: Monitoring — SHB + Custom Collectors

SHB's monitoring block provides Grafana, Prometheus, and Loki with auto-provisioned dashboards for all SHB services. Your custom bash collectors from Vol 2 feed additional metrics into the same Prometheus instance. The two complement each other without overlap.

Source

What It Monitors

Gets to Prometheus Via

Owned By

SHB dashboards

HTTP 5xx rates, service health

Auto-provisioned by shb.monitoring

SHB (automatic)

node_exporter

CPU, memory, disk, network

Standard Prometheus scrape

NixOS upstream module

Custom collector

VLAN boundary, conntrack, saturation

Bash on port 9100 (Vol 2 scripts)

homelab.monitoring module

Custom exporter

Monero sync %, peer count, hashrate

Custom on pi-monero:9101

homelab.monero module

Loki + journald

All systemd logs, structured queries

Auto-shipped by shb.monitoring

SHB (automatic)

▶ Feeding custom metrics into SHB's Prometheus

# Add your custom scrape targets to SHB's Prometheus:

services.prometheus.scrapeConfigs = [

  { job_name = "homelab-collectors";

    static_configs = [{

      targets = [

        "10.10.0.1:9100"   # router custom collector

        "10.20.0.2:9100"   # pi-monero custom collector

        "10.20.0.2:9101"   # monero-specific exporter

        "10.30.0.1:9100"   # nuc custom collector

      ];

      labels.source = "homelab";

    }];

  }

];

Section 10: Repository Structure

This is the target file layout. It shows exactly where Skarabox options, SHB imports, custom modules, and host configs live. The structure mirrors the three-layer architecture.

homelab/

├─ flake.nix                    # Skarabox + SHB + flake-parts

├─ flake.lock

├─ configuration.nix             # Shared options (all hosts)

├─ keys.txt                      # Your SOPS age key

│

├─ modules/                      # LAYER 3: Custom (Vol 1-2)

│  ├─ networking/

│  │  ├─ vlans.nix              # VLAN topology + firewall

│  │  └─ options.nix            # types: attrsOf submodule

│  ├─ monitoring/

│  │  ├─ default.nix            # Collector implementation

│  │  ├─ options.nix            # types: port, listOf targets

│  │  └─ scripts/               # Bash collectors (Vol 2)

│  ├─ dns/default.nix            # Recipe 1: DNS resolver

│  ├─ diagnostics/default.nix    # Recipe 6: Role-based tools

│  ├─ backups/default.nix        # Recipe 2: rsync (non-Restic)

│  ├─ logging/default.nix        # Recipe 4: rotation policy

│  ├─ scheduled-jobs/default.nix # Recipe 3: systemd timers

│  ├─ secrets/default.nix        # Recipe 7: bridges to shb.sops

│  └─ roles/                     # Composite role modules

│     ├─ router.nix

│     ├─ core-services.nix

│     └─ node.nix

│

├─ hosts/                        # Per-host (Skarabox schema)

│  ├─ router/

│  │  ├─ configuration.nix      # Host-specific: IPs, ifaces

│  │  └─ secrets.yaml           # SOPS encrypted

│  ├─ nuc/

│  │  ├─ configuration.nix      # SHB services + custom

│  │  └─ secrets.yaml

│  ├─ pi-monero/

│  │  ├─ configuration.nix

│  │  └─ secrets.yaml

│  └─ pi-vpn/

│     ├─ configuration.nix

│     └─ secrets.yaml

│

└─ docs/                         # This reference series

   ├─ vol1-nix-types-reference.docx

   ├─ vol2-extended-recipes.docx

   └─ vol3-skarabox-deployment.docx

Section 11: Flake Template

The flake.nix that wires Skarabox, SHB, and your custom modules. Follows Skarabox's flake-parts pattern with SHB's patched nixpkgs.

{

  inputs = {

    selfhostblocks.url = "github:ibizaman/selfhostblocks";

    skarabox.url = "github:ibizaman/skarabox";

    flake-parts.url = "github:hercules-ci/flake-parts";

  };

  outputs = { self, flake-parts, skarabox, selfhostblocks, ... }:

    flake-parts.lib.mkFlake { inherit self; } {

      imports = [ skarabox.flakeModules.default ];

      systems = [ "x86_64-linux" "aarch64-linux" ];

      skarabox = {

        sopsKeyPath = "keys.txt";

        hosts.router = {

          ip = "10.10.0.1";

          system = "aarch64-linux";

          sshPort = 2222;

          sshBootPort = 2223;

          secretsFilePath = ./hosts/router/secrets.yaml;

          modules = [

            selfhostblocks.nixosModules.default

            ./modules/roles/router.nix

            ./hosts/router/configuration.nix

          ];

        };

        hosts.nuc = {

          ip = "10.30.0.1";

          system = "x86_64-linux";

          sshPort = 2222;

          secretsFilePath = ./hosts/nuc/secrets.yaml;

          modules = [

            selfhostblocks.nixosModules.default

            ./modules/roles/core-services.nix

            ./hosts/nuc/configuration.nix

          ];

        };

        hosts.pi-monero = {

          ip = "10.20.0.2";

          system = "aarch64-linux";

          sshPort = 2222;

          secretsFilePath = ./hosts/pi-monero/secrets.yaml;

          modules = [

            selfhostblocks.nixosModules.default

            ./modules/roles/node.nix

            ./hosts/pi-monero/configuration.nix

          ];

        };

      };

    };

}

Section 12: Design Tradeoffs — What to Enforce vs Compromise

When resources are tight (your homelab is Pis and a NUC, not a data center), choose consciously. These tradeoffs are the architectural decisions that typed modules encode.

✓ Always Enforce (non-negotiable in your type system)

Secrets in Git are encrypted (SOPS, skarabox.secretsFilePath)

SSH keys only, no passwords (skarabox.hostKeyPath)

Backups for critical data (shb.restic via contract)

Git as source of truth (every config change = Nix module change)

Clear management path (MGMT VLAN + SSH via skarabox tools)

Trust boundary enforcement (custom firewall rules per VLAN)

Build-time validation (types.enum, types.port, types.between)

⚠ Acceptable Compromises (for a homelab, not a DC)

Single points of failure: one router, one NUC, one storage target

  → Rely on simple restore (beacon + install) rather than HA clustering

No full HA: services have minutes of downtime during redeploy

  → Acceptable for personal infrastructure

Shared VLANs: NUC runs services + monitoring on same VLAN

  → Separate by firewall rules, not physical isolation

Some repetition: role modules may duplicate a few options

  → Prefer clarity over over-abstracted, hard-to-debug code

Single-host SHB stack: all services on one NUC

  → Scale to second host only when NUC is provably overloaded

Section 13: Step-by-Step Deployment Checklist

Integrates the Skarabox lifecycle, SHB service deployment, custom modules, and validation into a single sequence. Each step references the tool, module, and pipeline.

#

Action

Tool / Module

Validate With

1

Define zones: MGMT, PUBLIC, PRIVATE

Design (whiteboard)

Network diagram in docs/

2

Initialize repo with Skarabox

nix run skarabox#init

ls flake.nix configuration.nix

3

Generate host entries

nix run .#gen-new-host <n>

cat hosts/<n>/configuration.nix

4

Add SHB + custom module inputs

Edit flake.nix

nix flake check

5

Write custom modules (Vol 1-2 types)

modules/*.nix

nix eval .#nixosConfigurations.<host>

6

Write role modules composing SHB + custom

modules/roles/*.nix

nix build .#nixosConfigurations.<host>

7

Create SOPS secrets per host

nix run .#sops ./hosts/<n>/secrets.yaml

sops -d ./hosts/<n>/secrets.yaml

8

Build beacon ISO for first host

nix run .#<host>-beacon

ls result/iso/beacon.iso

9

Test in VM before real hardware

nix run .#<host>-beacon-vm

SSH into VM, verify boot + disks

10

Flash beacon to USB, boot target

dd if=beacon.iso of=/dev/sdX

ping <host-ip>

11

Install NixOS on target

nix run .#<host>-install-on-beacon

SSH confirms system booted

12

Unlock encrypted root

nix run .#<host>-unlock

nix run .#<host>-ssh 'uptime'

13

Deploy full config

nix run .#deploy-rs

systemctl list-units --failed

14

Verify SHB services

curl https://vault.example.com

Grafana dashboards show green

15

Verify custom monitoring

curl http://<host>:9100/metrics

Prometheus targets page: UP

16

Test backup + restore

restic -r <repo> snapshots

Diff restore against source

17

Test full recovery

Wipe VM, beacon + install from scratch

All services back, zero manual steps

18

Re-evaluate scope

Review, iterate

Only add services once basics are solid

✓ The Complete Stack: Pipeline → Type → Module → Host → Service

Diagnostic question    ("Is VLAN leaking?")

 → Bash pipeline        tcpdump | grep | uniq -c

 → Custom collector     Prometheus text format on :9100

 → Typed Nix module     homelab.monitoring.boundary (Vol 1-2)

 → Role module          modules/roles/router.nix

 → Skarabox host        skarabox.hosts.router (beacon, deploy, unlock)

 → SHB Prometheus       shb.monitoring (auto-scrapes collector)

 → SHB Grafana          Dashboard shows boundary violation spike

 → Alert fires          You SSH in: nix run .#router-ssh

 → Run the pipeline     The same commands that built the collector

Every layer: cohesive, decoupled, typed, replaceable.

Skarabox = host lifecycle. SHB = service composition.

Your modules = what's unique to YOUR homelab.

The Nix type system is the contract holding it all together.
