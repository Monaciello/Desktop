# Nix Types Networking Reference

Nix Option Types

for Network Infrastructure

Type Reference × Error Scenarios × Architecture Patterns

Core Principle

Nix option types enforce at build time what would otherwise be runtime failures on your network. Every type declaration is simultaneously a validation rule, a piece of architecture documentation, and a contract between modules that can never be silently violated.

Think of types as the IEEE standards of your Nix configuration: types.port is to your module what 802.1Q is to your switch. Both define what valid data looks like before it enters the system.

Section 1: Primitive Types — Scalar Values

Primitive types constrain a single value. In networking, these map to individual configuration parameters: a port number, a toggle, an interface name. Each primitive type encodes domain knowledge about what values make sense.

1.1  types.bool — Binary State

A bool represents an on/off decision with no middle ground. In networking, this models features that are either active or inactive: a firewall rule, a NAT gateway, a monitoring collector.

# Declaration

options.homelab.monitoring.enable = mkOption {

  type = types.bool;

  default = false;

  description = "Enable the monitoring stack";

};

# Usage in implementation

config = mkIf cfg.enable { ... };

Networking analogy: A bool is a physical switch on a patch panel. The port is either live or dead. There is no "kind of connected."

✗ ERROR: Type violation: passing a string where bool expected

homelab.monitoring.enable = "yes";

error: A definition for option 'homelab.monitoring.enable'

is not of type 'bool'. Definition values: "yes"

⚠ WHY: Without this type, the string "yes" passes silently

The bash script receives ENABLE="yes" as an env var.

[ "$ENABLE" = true ] evaluates to FALSE (string mismatch).

Your monitoring stack silently doesn't start.

You debug for 30 minutes before finding the typo.

1.2  types.str / types.nonEmptyStr — Text Values

Strings represent names, addresses, identifiers. The difference between str and nonEmptyStr is the difference between "any cable" and "a cable that's actually plugged in."

# types.str accepts any string including ""

options.hostName = mkOption {

  type = types.str;  # allows empty string

};

# types.nonEmptyStr rejects ""

options.vlan.range = mkOption {

  type = types.nonEmptyStr;  # "" is caught at build time

  example = "10.20";

};

✗ ERROR: Empty string passed to nonEmptyStr

homelab.monitoring.vlans.vlan20.range = "";

error: The value "" is not a valid value of type

'non-empty string'.

⚠ WHY: Without nonEmptyStr, empty strings cause silent failures

grep "" in a pipeline matches EVERY line.

Your VLAN boundary checker reports everything as a violation.

tcpdump -i "" fails with 'no such device'.

The error appears at 3 AM, not at deploy time.

1.3  types.port — Network Port Number

This is the most networking-specific primitive type. It constrains an integer to the range 0–65535, encoding the TCP/UDP port number specification directly into the type system. Think of it as a type that has read RFC 793.

options.metricsPort = mkOption {

  type = types.port;     # integer, 0-65535

  default = 9100;        # Prometheus node_exporter convention

};

# Used in implementation:

networking.firewall.allowedTCPPorts = [ cfg.metricsPort ];

# Environment var for the bash collector:

environment.METRICS_PORT = toString cfg.metricsPort;

✗ ERROR: Port number out of range

homelab.monitoring.metricsPort = 99999;

error: A definition for 'homelab.monitoring.metricsPort'

is not of type 'port (integer between 0 and 65535)'.

Definition values: 99999

✗ ERROR: String instead of integer

homelab.monitoring.metricsPort = "9100";

error: A definition for 'homelab.monitoring.metricsPort'

is not of type 'port'. Definition values: "9100"

⚠ WHY: Why types.port instead of types.int

types.int accepts 99999, -5, or 2147483647.

netcat -l -p 99999 silently fails or binds to wrong port.

iptables rule with port -5 creates an invalid firewall.

types.port catches ALL of these at nixos-rebuild time.

1.4  types.ints.between / types.ints.positive — Bounded Integers

When the standard integer range isn't specific enough, bounded integers let you encode domain-specific ranges. The classic networking example is VLAN IDs: the IEEE 802.1Q standard defines valid VLAN IDs as 1 through 4094.

# VLAN ID: IEEE 802.1Q says 1-4094

options.vlan.id = mkOption {

  type = types.ints.between 1 4094;

};

# Scrape interval: must be positive (0 = infinite loop)

options.scrapeInterval = mkOption {

  type = types.ints.positive;  # rejects 0 and negatives

  default = 15;

};

# MTU: practical range for Ethernet

options.mtu = mkOption {

  type = types.ints.between 68 9000;  # min IP MTU to jumbo frame

};

✗ ERROR: VLAN ID out of IEEE 802.1Q range

homelab.monitoring.vlans.vlan20.id = 5000;

error: A definition for 'homelab.monitoring.vlans.vlan20.id'

is not of type 'integer between 1 and 4094 (both inclusive)'.

Definition values: 5000

✗ ERROR: Zero scrape interval

homelab.monitoring.scrapeInterval = 0;

error: A definition for 'homelab.monitoring.scrapeInterval'

is not of type 'positive integer, meaning >0'.

Definition values: 0

⚠ WHY: Runtime consequence of invalid VLAN ID

ip link add link eth0 name vlan5000 type vlan id 5000

RTNETLINK answers: Invalid argument

Your network module deploys, but VLANs don't exist.

All inter-VLAN routing silently fails.

Section 2: types.enum — Constrained Choices

An enum restricts a value to one of an explicit set of options. In networking, enums model anything that has a fixed vocabulary: trust boundary classifications, protocol names, firewall actions, interface roles. An enum is like a patch panel with labeled ports; you can only plug into slots that exist.

# Trust boundary classification

options.vlan.role = mkOption {

  type = types.enum [ "public" "private" "management" ];

};

# Firewall default action

options.firewall.defaultPolicy = mkOption {

  type = types.enum [ "accept" "drop" "reject" ];

  default = "drop";

};

# Transport protocol

options.probe.protocol = mkOption {

  type = types.enum [ "icmp" "tcp" "udp" "http" ];

};

✗ ERROR: Typo in enum value

homelab.monitoring.vlans.vlan20.role = "pubilc";

error: The value "pubilc" is not a valid value of type

'one of "public", "private", "management"'.

Definition values: "pubilc"

⚠ WHY: Without enum, typos become security holes

Your firewall module checks: if role == "public" then ...

"pubilc" doesn't match any branch -> falls to default.

Default might be 'allow all' -> VLAN 20 has no firewall.

Enum catches the typo at build time, before deployment.

Enums also serve as documentation. Anyone reading the option declaration immediately knows what values are valid. Compare this to a types.str with a comment saying "should be public, private, or management." The comment can lie. The enum cannot.

Section 3: Composition Types — Collections of Values

Composition types build structured data from primitives. They model one-to-many relationships: a host monitors multiple interfaces, a network has multiple VLANs, a probe checks multiple targets. These are the types that let you describe infrastructure topology.

3.1  types.listOf — Ordered Collections

A list where every element must satisfy the inner type. In networking, lists model things like "all interfaces to monitor" or "all DNS servers to use." The list enforces homogeneity: every element is the same kind of thing.

# Every element must be a non-empty string

options.interfaces = mkOption {

  type = types.listOf types.nonEmptyStr;

  default = [ "eth0" ];

};

# Every element must be a valid port

options.firewall.allowedPorts = mkOption {

  type = types.listOf types.port;

  default = [ 22 80 443 ];

};

✗ ERROR: Mixed types in list

homelab.monitoring.interfaces = [ "eth0" 42 "vlan20" ];

error: A definition for 'homelab.monitoring.interfaces.[1]'

is not of type 'non-empty string'.

Definition values: 42

✗ ERROR: String instead of list

homelab.monitoring.interfaces = "eth0";

error: A definition for 'homelab.monitoring.interfaces'

is not of type 'list of non-empty string'.

Definition values: "eth0"

⚠ WHY: Why this matters for generated config files

The implementation does: concatStringsSep "," cfg.interfaces

If interfaces = "eth0" (string not list), concat operates

on characters: "e,t,h,0" -> your collector monitors nothing.

With listOf, Nix guarantees the concat receives a list.

3.2  types.attrsOf — Named Key-Value Collections

An attribute set where every value must satisfy the inner type. The keys are arbitrary strings chosen by the user. This models named infrastructure: VLANs, hosts, services. Think of it as a switch port panel where you label each port, and the type ensures every port has the same capabilities.

# Named VLANs: each must have an integer ID

options.vlans = mkOption {

  type = types.attrsOf types.int;

  example = { vlan20 = 20; vlan30 = 30; };

};

# Named hosts: each must have a string address

options.hosts = mkOption {

  type = types.attrsOf types.nonEmptyStr;

  example = { pi-monero = "10.20.0.2"; nuc = "10.30.0.1"; };

};

The real power of attrsOf emerges when combined with submodule (Section 4). On its own, attrsOf enforces that every named thing has the same type of value. Combined with submodule, every named thing has the same internal structure.

3.3  types.nullOr — Optional Values

Wraps any type to allow null as a valid value. This models "present or absent" semantics. In networking, the classic use case is an optional port number: null means "use ICMP ping" while a port number means "use TCP probe."

# Port is optional: null = ICMP, non-null = TCP probe

options.targets.*.port = mkOption {

  type = types.nullOr types.port;

  default = null;

};

# Implementation branches on null:

if t.port != null

  then "timeout 2 bash -c 'echo > /dev/tcp/${t.address}/${toString t.port}'"

  else "ping -c1 -W2 ${t.address}"

The nullOr type makes optional semantics explicit. Without it, you would use types.str with default = "" and check for empty strings. But empty string and absent are semantically different: an empty port string might be a bug, while null is an intentional choice to use ICMP.

✗ ERROR: Invalid value inside nullOr

targets = [{ name = "pi"; address = "10.20.0.2"; port = -1; }];

error: A definition for 'targets.[0].port'

is not of type 'null or port'. Definition values: -1

# null is valid, a valid port is valid, but -1 is neither.

Section 4: types.submodule — Structured Records

Submodule is the most powerful composition type. It defines a record with named, typed fields, essentially a schema for structured data. In networking, submodules model anything with internal structure: a VLAN (has ID, range, and role), a probe target (has name, address, and optional port), or a firewall rule (has source, destination, action, and protocol).

The analogy: a submodule is a wiring standard. Just as T568B specifies which wire goes to which pin, a submodule specifies which fields exist and what types they hold. Any configuration that follows the standard works. Any that doesn't is rejected before it reaches the network.

# VLAN submodule: every VLAN must have this structure

options.vlans = mkOption {

  type = types.attrsOf (types.submodule {

    options = {

      range = mkOption {

        type = types.nonEmptyStr;

        description = "IP prefix (e.g. 10.20)";

      };

      id = mkOption {

        type = types.ints.between 1 4094;

        description = "IEEE 802.1Q VLAN ID";

      };

      role = mkOption {

        type = types.enum [ "public" "private" "management" ];

      };

    };

  });

};

Submodule Error Scenarios

✗ ERROR: Missing required field

vlans.vlan20 = { range = "10.20"; id = 20; };

# role is not defined and has no default!

error: The option 'homelab.monitoring.vlans.vlan20.role'

is used but not defined.

✗ ERROR: Extra field that doesn't exist in schema

vlans.vlan20 = { range = "10.20"; id = 20;

  role = "public"; gateway = "10.20.0.1"; };

error: The option 'homelab.monitoring.vlans.vlan20.gateway'

does not exist.

✗ ERROR: Correct field name, wrong type inside submodule

vlans.vlan20 = { range = "10.20"; id = "twenty";

  role = "public"; };

error: A definition for

'homelab.monitoring.vlans.vlan20.id' is not of type

'integer between 1 and 4094'. Definition values: "twenty"

⚠ WHY: Why submodule catches what plain attrsOf cannot

types.attrsOf types.str would accept:

  vlans.vlan20 = { range = "10.20"; color = "blue"; }

No schema enforcement. Your implementation reads .id and crashes.

Submodule guarantees every VLAN has exactly the right fields.

Nested Submodules: types.listOf (types.submodule)

When you need an ordered collection of structured records, combine listOf with submodule. This models probe targets, firewall rules, routing table entries, or any list where each item has internal structure.

# Probe targets: ordered list of structured records

options.targets = mkOption {

  type = types.listOf (types.submodule {

    options = {

      name    = mkOption { type = types.nonEmptyStr; };

      address = mkOption { type = types.nonEmptyStr; };

      port    = mkOption {

        type = types.nullOr types.port;

        default = null;

      };

    };

  });

  default = [];

};

# Usage:

targets = [

  { name = "router";  address = "10.0.0.1";  port = null; }

  { name = "pi-vpn";  address = "10.20.0.3"; port = 51820; }

  { name = "pi-dns";  address = "10.10.0.1"; port = 53; }

];

✗ ERROR: Malformed target in list

targets = [

  { name = "router"; address = "10.0.0.1"; }   # OK (port defaults null)

  { name = ""; address = "10.20.0.3"; port = 51820; }  # empty name!

];

error: A definition for 'targets.[1].name'

is not of type 'non-empty string'. Definition values: ""

Section 5: Complete Type-to-Networking Reference

The following table maps every relevant Nix type to its networking use case, the constraint it enforces, and a physical analogy to help internalize the concept.

Nix Type

Networking Use Case

Constraint

Physical Analogy

types.bool

Feature toggle (NAT, monitoring, VPN)

true or false only

Switch on a patch panel

types.str

Free-form text (descriptions, comments)

Any string including empty

Unlabeled cable

types.nonEmptyStr

Interface name, IP prefix, hostname

String, must not be ""

Labeled cable (label required)

types.port

TCP/UDP port number

Integer 0–65535

Numbered port on a switch

types.ints.positive

Interval, count, timeout

Integer > 0

Timer dial (can't be zero)

types.ints.between

VLAN ID (1–4094), MTU (68–9000)

Integer in exact range

Standard-compliant connector

types.enum [...]

Trust role, protocol, firewall action

One of listed values only

Keyed connector (only fits right socket)

types.listOf T

Interfaces, ports, DNS servers

Every element is type T

Rack of identical slots

types.attrsOf T

Named hosts, named VLANs

Every value is type T, keys are free

Labeled rack of identical slots

types.nullOr T

Optional port, optional gateway

Either null or valid T

Port with dust cap (cap = unused)

types.submodule

VLAN def, probe target, firewall rule

Record with typed named fields

Wiring standard (pin 1 = data, pin 2 = ...)

types.path

Script path, cert file, key file

Must be a filesystem path

Patch cord (must connect somewhere)

Section 6: Error Scenario Matrix — What Breaks and Why

This matrix summarizes the most common type errors encountered when configuring network infrastructure in NixOS. For each scenario, it shows the invalid configuration, the build-time error message, and the runtime failure that the type system prevented.

What You Wrote

What Nix Says

What Would Break at Runtime

enable = "yes";

not of type 'bool'

Script checks $ENABLE = true, string "yes" fails comparison, monitoring silently disabled

vlans.vlan20.range = "";

not a valid 'non-empty string'

grep "" matches all lines, boundary checker flags every packet as a violation

metricsPort = 99999;

not of type 'port'

nc -l -p 99999 silently fails, Prometheus scrape target unreachable

metricsPort = "9100";

not of type 'port'

toString on a string is identity; firewall rule gets string not int, iptables rejects

vlans.vlan20.id = 5000;

not between 1 and 4094

ip link add vlan id 5000 fails: RTNETLINK Invalid argument

vlans.vlan20.role = "pubilc";

not one of "public"...

Firewall role match fails, VLAN gets no rules, defaults to allow-all

interfaces = "eth0";

not of type 'list of...'

concatStringsSep operates on chars: "e,t,h,0", monitors nothing

interfaces = [ "" "eth0" ];

not 'non-empty string'

cat /sys/class/net//statistics fails, collector crashes

scrapeInterval = 0;

not 'positive integer'

sleep 0 in loop = infinite CPU spin, Pi overheats

targets = [{ name = "pi"; }];

option 'address' is used but not defined

ping "" resolves to localhost, reports false UP status

vlans.vlan20.gateway = "...";

option 'gateway' does not exist

Submodule schema prevents config drift: only declared fields accepted

targets[0].port = -1;

not of type 'null or port'

echo > /dev/tcp/host/-1 is invalid, probe hangs then times out

Section 7: Type Pattern Recipes

These are copy-paste patterns for common networking configuration scenarios. Each recipe shows the option declaration, a valid usage example, and the implementation pattern that consumes the typed value.

Recipe: Firewall Rule Set

options.firewall.rules = mkOption {

  type = types.listOf (types.submodule {

    options = {

      direction = mkOption { type = types.enum ["in" "out" "forward"]; };

      protocol  = mkOption { type = types.enum ["tcp" "udp" "icmp"]; };

      port      = mkOption { type = types.nullOr types.port; default = null; };

      source    = mkOption { type = types.nullOr types.nonEmptyStr; default = null; };

      action    = mkOption { type = types.enum ["accept" "drop" "reject"]; };

    };

  });

};

# Usage:

firewall.rules = [

  { direction="in"; protocol="tcp"; port=22; source="10.10.0.0/24";

    action="accept"; }   # SSH from mgmt VLAN only

  { direction="in"; protocol="tcp"; port=9100; source=null;

    action="accept"; }   # Prometheus scrape from anywhere

  { direction="forward"; protocol="icmp"; port=null; source="10.20.0.0/24";

    action="drop"; }     # Block ICMP forwarding from public VLAN

];

Recipe: WireGuard Peer Definition

options.vpn.peers = mkOption {

  type = types.attrsOf (types.submodule {

    options = {

      publicKey     = mkOption { type = types.nonEmptyStr; };

      allowedIPs    = mkOption { type = types.listOf types.nonEmptyStr; };

      endpoint      = mkOption { type = types.nullOr types.nonEmptyStr;

                                 default = null; };  # null = no fixed endpoint

      persistentKeepalive = mkOption {

        type = types.nullOr types.ints.positive;

        default = null;  # null = disabled

      };

    };

  });

};

# Usage:

vpn.peers.phone = {

  publicKey = "abc123...";

  allowedIPs = [ "10.200.0.2/32" ];

  endpoint = null;            # mobile, no fixed IP

  persistentKeepalive = 25;   # keep NAT alive

};

Recipe: Multi-Host Collector Config

options.collector = {

  enable     = mkOption { type = types.bool; default = false; };

  port       = mkOption { type = types.port; default = 9100; };

  interval   = mkOption { type = types.ints.positive; default = 15; };

  interfaces = mkOption { type = types.listOf types.nonEmptyStr;

                          default = [ "eth0" ]; };

  vlans = mkOption {

    type = types.attrsOf (types.submodule {

      options = {

        range = mkOption { type = types.nonEmptyStr; };

        id    = mkOption { type = types.ints.between 1 4094; };

        role  = mkOption { type = types.enum [ "public" "private"

                           "management" ]; };

      };

    });

    default = {};

  };

  targets = mkOption {

    type = types.listOf (types.submodule {

      options = {

        name    = mkOption { type = types.nonEmptyStr; };

        address = mkOption { type = types.nonEmptyStr; };

        port    = mkOption { type = types.nullOr types.port;

                             default = null; };

      };

    });

    default = [];

  };

};

Section 8: Types Bridge Linux Pipelines to Nix Declarations

Every monitoring pipeline from the diagnostic playbook maps to a typed Nix configuration. The pipeline defines what data flows; the type system defines what valid configuration looks like. Together, they form a complete system where mistakes are caught at build time and operations are validated in real time.

Concern

Bash Pipeline

Nix Type That Configures It

Reachability

ping / ss -tln / curl

types.listOf submodule { name, address, nullOr port }

Throughput

cat /sys/.../rx_bytes

types.listOf nonEmptyStr (interface names)

VLAN health

tcpdump | grep foreign

types.attrsOf submodule { range, id, role }

Connection sat.

conntrack -C / ss -tn

types.attrsOf submodule (VLAN ranges + names)

Firewall valid.

iptables -L -v -n

types.listOf submodule { direction, protocol, ... }

Service port

nc -l -p PORT

types.port (guarantees 0–65535)

Feature toggle

if [ "$ENABLE" = true ]

types.bool (prevents string "yes" / "true")

The Complete Feedback Loop

Diagnostic question  →  Bash pipeline (answers it once)  →  Bash collector script (answers it continuously)  →  Nix module (deploys it declaratively)  →  Nix types (validate the config at build time)  →  Prometheus scrapes the endpoint  →  Grafana visualizes  →  Alert fires  →  You run the diagnostic pipeline manually to confirm

Every layer is cohesive (one concern), decoupled (explicit interfaces), and the type system is the contract that prevents misconfiguration from reaching your network.
