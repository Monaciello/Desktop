# Nix Types Vol2 Extended Recipes

Nix Option Types

for Network Infrastructure

Volume 2: Extended Recipes

DNS • Rsync & Backups • Cron & Systemd Timers • Log Management • Certificate Lifecycle • Network Diagnostics

How to Read These Recipes

Each recipe follows a three-layer structure that mirrors how infrastructure is actually built: the diagnostic pipeline (what question are we answering?), the Nix option declaration (what does valid configuration look like?), and the error scenarios (what breaks if we get it wrong?). Green pipeline boxes show the bash commands. Purple recipe headers name the pattern. Red error boxes show build-time rejections. Orange warning boxes show the runtime failure that was prevented.

Every recipe is designed to be copy-pasted into a NixOS module and adapted to your homelab topology.

Recipe 1

DNS Infrastructure

Local resolver, upstream fallback, split-horizon, and monitoring

DNS is the nervous system of your network. Every service lookup, every hostname resolution, every VLAN-aware name depends on it. When DNS breaks, everything breaks. The Nix type system lets you define your entire DNS topology declaratively and catch misconfigurations before they blackhole your network.

The Diagnostic Pipeline

Before declaring DNS in Nix, you need to know what questions to ask and how to ask them with bash pipelines. These are the commands your monitoring will automate.

▶ PIPELINE: Is my local resolver working?

# Compare resolution time: local vs external

dig +stats example.com @10.10.0.1 | grep 'Query time'

dig +stats example.com @1.1.1.1   | grep 'Query time'

# Check if Pi-hole is actually filtering

dig +short ads.tracking.com @10.10.0.1   # should return 0.0.0.0

dig +short ads.tracking.com @1.1.1.1     # returns real IP

# Batch-test critical domains resolve correctly

printf '%s\n' github.com api.example.com internal.lan |

  xargs -I{} sh -c 'echo "{}: $(dig +short {} @10.10.0.1)"'

▶ PIPELINE: DNS health monitoring (collector pattern)

# Output Prometheus gauge: 1 = resolving, 0 = broken

echo '# TYPE dns_resolution_success gauge'

for domain in github.com google.com; do

  result=$(dig +short +time=2 $domain @10.10.0.1 2>/dev/null)

  [ -n "$result" ] && v=1 || v=0

  echo "dns_resolution_success{domain=\"$domain\"} $v"

done

# Query latency as histogram-style metric

echo '# TYPE dns_query_ms gauge'

ms=$(dig +stats example.com @10.10.0.1 |

     grep 'Query time' | awk '{print $4}')

echo "dns_query_ms{server=\"10.10.0.1\"} $ms"

Nix Option Declaration

This module declares a complete DNS infrastructure: a local resolver, upstream servers with failover, custom local records, and monitoring probes. Each type choice encodes a DNS-specific constraint.

options.homelab.dns = {

  enable = mkOption {

    type = types.bool;

    default = false;

  };

  # Which host runs the resolver

  listenAddress = mkOption {

    type = types.nonEmptyStr;

    default = "0.0.0.0";

    description = "Address the DNS server binds to";

  };

  port = mkOption {

    type = types.port;

    default = 53;

  };

  # Upstream resolvers with failover ordering

  upstreams = mkOption {

    type = types.listOf (types.submodule {

      options = {

        address = mkOption { type = types.nonEmptyStr; };

        port    = mkOption { type = types.port; default = 53; };

        name    = mkOption { type = types.nonEmptyStr; };

        tls     = mkOption {

          type = types.bool;

          default = false;

          description = "Use DNS-over-TLS";

        };

      };

    });

    description = "Ordered list: first = primary, rest = fallback";

  };

  # Split-horizon: different answers for internal vs external

  localRecords = mkOption {

    type = types.attrsOf (types.submodule {

      options = {

        type = mkOption {

          type = types.enum [ "A" "AAAA" "CNAME" "TXT" "MX" ];

        };

        value = mkOption { type = types.nonEmptyStr; };

        ttl = mkOption {

          type = types.ints.positive;

          default = 300;  # 5 minutes

          description = "TTL in seconds";

        };

      };

    });

    default = {};

    description = "Local DNS records (key = hostname)";

  };

  # Domains to block (ad-blocking / privacy)

  blocklists = mkOption {

    type = types.listOf types.nonEmptyStr;

    default = [];

    description = "URLs of domain blocklists";

  };

  # Monitoring: which domains to probe

  probes = mkOption {

    type = types.listOf (types.submodule {

      options = {

        domain = mkOption { type = types.nonEmptyStr; };

        expectedResult = mkOption {

          type = types.nullOr types.nonEmptyStr;

          default = null;  # null = just check it resolves

          description = "Expected IP (null = any response is OK)";

        };

      };

    });

    default = [];

  };

};

Usage: Your Homelab DNS

# hosts/pi-dns.nix

homelab.dns = {

  enable = true;

  listenAddress = "10.10.0.1";

  upstreams = [

    { name = "cloudflare"; address = "1.1.1.1";

      tls = true; port = 853; }

    { name = "quad9";      address = "9.9.9.9";

      tls = true; port = 853; }

    { name = "local-fallback"; address = "10.0.0.1";

      tls = false; port = 53; }  # ISP router as last resort

  ];

  localRecords = {

    "pi-monero.lan" = { type = "A"; value = "10.20.0.2"; };

    "pi-vpn.lan"    = { type = "A"; value = "10.20.0.3"; };

    "nuc.lan"        = { type = "A"; value = "10.30.0.1"; };

    "grafana.lan"    = { type = "CNAME"; value = "nuc.lan";

                         ttl = 60; };

  };

  blocklists = [

    "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

  ];

  probes = [

    { domain = "github.com"; expectedResult = null; }

    { domain = "pi-monero.lan"; expectedResult = "10.20.0.2"; }

    { domain = "ads.tracking.com"; expectedResult = "0.0.0.0"; }

  ];

};

Error Scenarios

✗ ERROR: Invalid DNS record type

localRecords."nuc.lan" = { type = "SRV"; value = "..."; };

error: The value "SRV" is not a valid value of type

'one of "A", "AAAA", "CNAME", "TXT", "MX"'.

⚠ Without the enum, SRV passes silently

Your DNS config generator outputs: "nuc.lan SRV 10.30.0.1"

dnsmasq or CoreDNS silently ignores the malformed record.

nuc.lan doesn't resolve. You debug DNS for an hour.

The enum catches it in 2 seconds at nixos-rebuild time.

✗ ERROR: Empty domain in probe list

probes = [{ domain = ""; expectedResult = null; }];

error: A definition for 'probes.[0].domain'

is not of type 'non-empty string'. Definition values: ""

⚠ Empty domain in dig = unexpected behavior

dig +short "" @10.10.0.1 queries the ROOT zone.

Returns root nameserver IPs instead of an error.

Your probe reports "UP" because it got a response.

But it tested nothing useful. types.nonEmptyStr prevents this.

✗ ERROR: TTL of zero

localRecords."nuc.lan" = { type = "A"; value = "10.30.0.1"; ttl = 0; };

error: A definition for 'localRecords."nuc.lan".ttl'

is not of type 'positive integer, meaning >0'. Values: 0

⚠ TTL=0 causes DNS storm

Every single lookup for nuc.lan hits your Pi-DNS.

No client or intermediate resolver caches the answer.

50 devices polling every second = 50 queries/sec for one name.

Your Pi Zero's dnsmasq falls over. All DNS stops.

Recipe 2

Rsync & Backup Infrastructure

Declarative backup jobs with typed source/destination pairs, retention, and health checks

Backups are the one infrastructure component where silent misconfiguration costs the most. A firewall typo might block traffic for an hour. A backup typo means data loss when you need recovery most. The type system here isn't just convenience; it's insurance.

The Diagnostic Pipeline

▶ PIPELINE: Verify backup health

# Check last backup timestamp

stat -c '%Y %n' /mnt/backups/*/latest |

  awk -v now=$(date +%s) '{age=(now-$1)/3600;

    if(age>24) print "STALE " age"h: " $2}'

# Compare source and destination sizes

du -sh /home/data/ /mnt/backups/data/latest/

# Dry-run rsync to see what WOULD transfer

rsync -avn --delete /home/data/ /mnt/backups/data/staging/

# -a archive, -v verbose, -n dry-run

# Prometheus metric: backup age in hours

echo '# TYPE backup_age_hours gauge'

for dir in /mnt/backups/*/latest; do

  name=$(basename $(dirname $dir))

  age=$(( ($(date +%s) - $(stat -c '%Y' $dir)) / 3600 ))

  echo "backup_age_hours{job=\"$name\"} $age"

done

Nix Option Declaration

options.homelab.backups = {

  enable = mkOption {

    type = types.bool;

    default = false;

  };

  jobs = mkOption {

    type = types.attrsOf (types.submodule {

      options = {

        source = mkOption {

          type = types.nonEmptyStr;

          description = "Source path or remote (user@host:/path)";

        };

        destination = mkOption {

          type = types.nonEmptyStr;

          description = "Destination path";

        };

        schedule = mkOption {

          type = types.nonEmptyStr;

          description = "systemd OnCalendar expression";

          example = "*-*-* 02:00:00";  # daily 2 AM

        };

        mode = mkOption {

          type = types.enum [ "mirror" "incremental"

                              "snapshot" ];

          default = "mirror";

          description = ''

            mirror: exact copy with --delete

            incremental: keep changed files

            snapshot: hardlink-based rotation

          '';

        };

        retentionDays = mkOption {

          type = types.ints.positive;

          default = 30;

          description = "Days to keep old snapshots";

        };

        bandwidth = mkOption {

          type = types.nullOr types.ints.positive;

          default = null;  # null = unlimited

          description = "KB/s limit (null = no limit)";

        };

        sshKey = mkOption {

          type = types.nullOr types.path;

          default = null;  # null = local backup, no SSH

          description = "SSH key for remote backups";

        };

        preHook = mkOption {

          type = types.nullOr types.nonEmptyStr;

          default = null;

          description = "Script to run before backup";

          example = "systemctl stop postgres";

        };

        postHook = mkOption {

          type = types.nullOr types.nonEmptyStr;

          default = null;

          description = "Script to run after backup";

          example = "systemctl start postgres";

        };

      };

    });

    default = {};

  };

  alertStaleHours = mkOption {

    type = types.ints.positive;

    default = 26;  # buffer over 24h schedule

    description = "Alert if backup is older than N hours";

  };

};

Usage: Homelab Backup Jobs

# hosts/nuc.nix

homelab.backups = {

  enable = true;

  alertStaleHours = 26;

  jobs = {

    monero-chain = {

      source = "pi-monero:/mnt/ssd/monero/";

      destination = "/mnt/backups/monero-chain/";

      schedule = "*-*-* 03:00:00";

      mode = "incremental";  # chain is append-mostly

      retentionDays = 7;

      sshKey = /etc/secrets/backup-key;

      bandwidth = 5000;  # 5 MB/s, don't starve the Pi

    };

    grafana-data = {

      source = "/var/lib/grafana/";

      destination = "/mnt/backups/grafana/";

      schedule = "*-*-* 02:00:00";

      mode = "snapshot";

      retentionDays = 90;

      preHook = "systemctl stop grafana";

      postHook = "systemctl start grafana";

    };

    nix-configs = {

      source = "/etc/nixos/";

      destination = "/mnt/backups/nixos-config/";

      schedule = "hourly";

      mode = "snapshot";

      retentionDays = 365;

    };

  };

};

How the Implementation Consumes Types

The implementation module reads the typed options and generates rsync commands. Notice how each type directly prevents a class of rsync error:

# Generated rsync command from typed options:

ExecStart = concatStringsSep " " (flatten [

  "${pkgs.rsync}/bin/rsync"

  "-a"                           # archive mode always

  (optional (cfg.mode == "mirror") "--delete")

  (optional (cfg.bandwidth != null)

    "--bwlimit=${toString cfg.bandwidth}")

  (optional (cfg.sshKey != null)

    "-e 'ssh -i ${cfg.sshKey}'")

  "${cfg.source}"

  "${cfg.destination}"

]);

Error Scenarios

✗ ERROR: Typo in backup mode

jobs.data.mode = "mirro";

error: The value "mirro" is not a valid value of type

'one of "mirror", "incremental", "snapshot"'.

⚠ "mirro" without enum = rsync runs without --delete

Implementation checks: if mode == "mirror" then "--delete"

"mirro" doesn't match, so --delete is omitted.

Your "mirror" accumulates stale files forever.

Backup disk fills up. You think you have space. You don't.

✗ ERROR: Zero retention days

jobs.data.retentionDays = 0;

error: not of type 'positive integer, meaning >0'. Values: 0

⚠ retentionDays=0 deletes ALL old backups immediately

find /mnt/backups -mtime +0 -delete

-mtime +0 means 'older than 0 days' = everything.

Your snapshot rotation deletes every previous backup.

When you need to recover, only the latest (possibly corrupt) exists.

✗ ERROR: Bandwidth limit of zero

jobs.data.bandwidth = 0;

error: not of type 'null or positive integer'. Values: 0

⚠ rsync --bwlimit=0 means unlimited, not zero

You intended to pause transfers. 0 actually means no limit.

Rsync saturates your Pi's network, starving Monero p2p.

nullOr types.ints.positive: null = no limit, positive = actual limit.

The type makes the semantics unambiguous.

Recipe 3

Scheduled Tasks: Cron vs Systemd Timers

Why NixOS uses systemd timers, OnCalendar syntax, and typed job definitions

Traditional cron is a flat file of magic strings. A typo in the schedule field silently skips your job. systemd timers are structured units that log, retry, and integrate with the system journal. NixOS models all scheduling through systemd, and the type system catches the most dangerous class of cron bugs: schedules that look valid but don't run when expected.

The Translation: Cron to systemd OnCalendar

Layer

What It Does

How It Connects

Cron syntax

0 2 * * *

Daily at 2 AM

OnCalendar

*-*-* 02:00:00

Same: daily at 2 AM

Cron syntax

*/15 * * * *

Every 15 minutes

OnCalendar

*:0/15

Same: every 15 min

Cron syntax

0 0 * * 0

Weekly on Sunday midnight

OnCalendar

Sun *-*-* 00:00:00

Same: Sunday midnight

Cron syntax

0 3 1 * *

Monthly 1st at 3 AM

OnCalendar

*-*-01 03:00:00

Same: 1st of month 3 AM

▶ PIPELINE: Verify systemd timer scheduling

# List all active timers and when they fire next

systemctl list-timers --all

# Check if a specific timer ran and its exit status

systemctl status backup-monero-chain.timer

journalctl -u backup-monero-chain.service --since today

# Prometheus metric: time since last successful run

echo '# TYPE systemd_timer_last_success_seconds gauge'

for svc in $(systemctl list-timers --no-legend |

  awk '{print $NF}'); do

  ts=$(systemctl show $svc -p ExecMainExitTimestamp \

       --value 2>/dev/null)

  [ -n "$ts" ] && epoch=$(date -d "$ts" +%s 2>/dev/null)

  [ -n "$epoch" ] &&

    echo "systemd_timer_last_success_seconds{unit=\"$svc\"}" \

         "$(( $(date +%s) - $epoch ))"

done

Nix Option Declaration

This module declares reusable scheduled jobs. The key design decision: schedule strings are typed as nonEmptyStr rather than a specialized calendar type. NixOS validates OnCalendar expressions at service activation, but the type system still prevents the most common mistake: an accidentally empty schedule that causes the timer to never fire.

options.homelab.scheduledJobs = mkOption {

  type = types.attrsOf (types.submodule {

    options = {

      command = mkOption {

        type = types.nonEmptyStr;

        description = "Command or script to execute";

      };

      schedule = mkOption {

        type = types.nonEmptyStr;

        description = "systemd OnCalendar expression";

        example = "*-*-* 02:00:00";

      };

      user = mkOption {

        type = types.nonEmptyStr;

        default = "root";

      };

      persistent = mkOption {

        type = types.bool;

        default = true;

        description = "Run immediately if missed";

      };

      timeout = mkOption {

        type = types.ints.positive;

        default = 3600;  # 1 hour

        description = "Kill job after N seconds";

      };

      restartOnFailure = mkOption {

        type = types.bool;

        default = false;

      };

      maxRetries = mkOption {

        type = types.ints.between 0 10;

        default = 0;

      };

      networkRequired = mkOption {

        type = types.bool;

        default = false;

        description = "Wait for network before running";

      };

      environment = mkOption {

        type = types.attrsOf types.str;

        default = {};

        description = "Environment variables for the job";

      };

    };

  });

  default = {};

};

Implementation: Types to systemd Units

The module implementation transforms each typed job definition into a pair of systemd units: a .service (what to run) and a .timer (when to run it). The type system guarantees every field is present and valid before systemd ever sees it.

# modules/scheduled-jobs/default.nix (implementation sketch)

config = {

  systemd.services = mapAttrs (name: job: {

    description = "Scheduled: ${name}";

    after = optional job.networkRequired

            [ "network-online.target" ];

    serviceConfig = {

      Type = "oneshot";

      User = job.user;

      ExecStart = job.command;

      TimeoutStartSec = job.timeout;

      Restart = if job.restartOnFailure

               then "on-failure" else "no";

      StartLimitBurst = job.maxRetries;

    };

    environment = job.environment;

  }) cfg.scheduledJobs;

  systemd.timers = mapAttrs (name: job: {

    wantedBy = [ "timers.target" ];

    timerConfig = {

      OnCalendar = job.schedule;

      Persistent = job.persistent;

    };

  }) cfg.scheduledJobs;

};

Usage: Homelab Scheduled Jobs

homelab.scheduledJobs = {

  rotate-logs = {

    command = "find /var/log -name '*.log' -mtime +30 -delete";

    schedule = "weekly";

    timeout = 300;

  };

  dns-blocklist-update = {

    command = "/etc/scripts/update-blocklists.sh";

    schedule = "*-*-* 04:00:00";  # daily 4 AM

    networkRequired = true;

    maxRetries = 3;

  };

  cert-renewal-check = {

    command = "/etc/scripts/check-certs.sh";

    schedule = "*-*-* 06:00:00";

    environment = {

      ALERT_WEBHOOK = "http://nuc.lan:9093/alert";

      WARN_DAYS = "30";

    };

  };

  monero-health = {

    command = "curl -sf http://10.20.0.2:18081/get_info";

    schedule = "*:0/5";  # every 5 minutes

    timeout = 30;

    restartOnFailure = false;

  };

};

Error Scenarios

✗ ERROR: Empty schedule string

scheduledJobs.cleanup.schedule = "";

error: A definition for 'scheduledJobs.cleanup.schedule'

is not of type 'non-empty string'. Definition values: ""

⚠ Empty OnCalendar = timer never activates

systemd-analyze calendar "" returns: Failed to parse.

The timer unit is created but never fires.

Your log rotation never runs. Disk fills up.

You discover weeks later when /var is at 100%.

✗ ERROR: Retries outside allowed range

scheduledJobs.backup.maxRetries = 100;

error: not of type 'integer between 0 and 10'. Values: 100

⚠ Excessive retries can create a retry storm

A failing backup retrying 100 times with default intervals

generates 100 rsync processes hammering a down remote host.

Each attempt holds network connections and disk I/O.

types.ints.between 0 10 caps retry storms by design.

Recipe 4

Log Management & Rotation

Structured log collection, rotation policies, and disk protection

Logs are the forensic evidence of your infrastructure. Too little logging and you can't debug. Too much and your Pi's SD card fills up and the system halts. The type system lets you define per-service log policies that balance observability with resource constraints, and catches the configuration mistakes that lead to disk exhaustion.

The Diagnostic Pipeline

▶ PIPELINE: Log health assessment

# Disk usage by log directory

du -sh /var/log/*/ 2>/dev/null | sort -hr | head

# Find logs not rotated in 30 days (potential leak)

find /var/log -name '*.log' -mtime +30 -size +10M \

  -exec ls -lh {} \;

# Error rate from journal (last hour)

journalctl --since '1 hour ago' -p err --no-pager |

  awk '{print $5}' | sort | uniq -c | sort -nr | head

# Prometheus metric: log partition usage

echo '# TYPE log_partition_usage_ratio gauge'

usage=$(df /var/log | awk 'NR==2 {print $5}' | tr -d '%')

echo "log_partition_usage_ratio $(awk \

  "BEGIN {printf \"%.2f\", $usage/100}")"

Nix Option Declaration

options.homelab.logging = {

  enable = mkOption {

    type = types.bool;

    default = true;

  };

  maxDiskPercent = mkOption {

    type = types.ints.between 10 90;

    default = 75;

    description = "Emergency rotate when /var/log exceeds this %";

  };

  journalMaxSize = mkOption {

    type = types.nonEmptyStr;

    default = "500M";

    description = "SystemMaxUse for journald";

  };

  policies = mkOption {

    type = types.attrsOf (types.submodule {

      options = {

        path = mkOption {

          type = types.nonEmptyStr;

          description = "Log file or glob pattern";

        };

        rotate = mkOption {

          type = types.enum ["daily" "weekly" "monthly"];

          default = "weekly";

        };

        keep = mkOption {

          type = types.ints.between 1 365;

          default = 4;

          description = "Number of rotated files to keep";

        };

        compress = mkOption {

          type = types.bool;

          default = true;

        };

        maxSize = mkOption {

          type = types.nonEmptyStr;

          default = "100M";

          description = "Rotate if file exceeds this size";

        };

      };

    });

    default = {};

  };

};

Usage: Pi-Friendly Log Policies

# hosts/pi-monero.nix  (SD card = precious space)

homelab.logging = {

  maxDiskPercent = 60;  # aggressive on constrained storage

  journalMaxSize = "200M";

  policies = {

    monero = {

      path = "/var/log/monero/*.log";

      rotate = "daily";

      keep = 7;         # one week of history

      compress = true;

      maxSize = "50M";  # rotate early if verbose

    };

    monitoring = {

      path = "/var/log/metrics.stream";

      rotate = "daily";

      keep = 3;         # metrics are in Prometheus anyway

      maxSize = "25M";

    };

  };

};

Error Scenarios

✗ ERROR: Disk threshold too low

homelab.logging.maxDiskPercent = 5;

error: not of type 'integer between 10 and 90'. Values: 5

⚠ maxDiskPercent=5 triggers constant emergency rotation

Most systems use >5% of /var/log at baseline.

Emergency rotation runs every check cycle.

Logs are deleted before you can read them.

types.ints.between 10 90 ensures a usable range.

✗ ERROR: Keep zero rotated files

policies.monero.keep = 0;

error: not of type 'integer between 1 and 365'. Values: 0

⚠ keep=0 means no history whatsoever

logrotate with rotate 0 deletes the old file immediately.

If monero crashes at 2:01 AM and logs rotate at 2:00 AM,

the crash log is gone. You have zero forensic evidence.

Minimum keep=1 guarantees at least one previous rotation exists.

Recipe 5

TLS Certificate Lifecycle

ACME automation, internal CA, expiry monitoring, and renewal scheduling

Expired certificates are the most common cause of "it worked yesterday" outages. The failure mode is invisible: the cert file exists, the service starts, but clients reject the handshake. Nix types enforce that every certificate has a renewal schedule, a validity check, and an alert threshold defined before it's ever deployed.

The Diagnostic Pipeline

▶ PIPELINE: Certificate health check

# Days until expiry for a live service

echo | openssl s_client -connect nuc.lan:443 2>/dev/null |

  openssl x509 -noout -enddate |

  cut -d= -f2 |

  xargs -I{} date -d '{}' +%s |

  awk -v now=$(date +%s) '{print ($1-now)/86400 " days"}'

# Check a certificate file directly

openssl x509 -in /etc/ssl/certs/nuc.pem \

  -noout -enddate -subject

# Batch check all certs in a directory

for cert in /etc/ssl/certs/*.pem; do

  expiry=$(openssl x509 -in $cert -noout -enddate \

           2>/dev/null | cut -d= -f2)

  days=$(( ($(date -d "$expiry" +%s) - $(date +%s)) / 86400 ))

  echo "$days days: $(basename $cert)"

done | sort -n

# Prometheus metric: certificate TTL

echo '# TYPE cert_expiry_days gauge'

for cert in /etc/ssl/certs/*.pem; do

  name=$(basename $cert .pem)

  expiry=$(openssl x509 -in $cert -noout -enddate \

    2>/dev/null | cut -d= -f2)

  [ -n "$expiry" ] && days=$(( ($(date -d "$expiry" +%s) \

    - $(date +%s)) / 86400 ))

  echo "cert_expiry_days{cert=\"$name\"} $days"

done

Nix Option Declaration

options.homelab.certs = {

  enable = mkOption {

    type = types.bool;

    default = false;

  };

  acmeEmail = mkOption {

    type = types.nonEmptyStr;

    description = "Email for ACME (Let's Encrypt) registration";

  };

  renewBeforeDays = mkOption {

    type = types.ints.between 7 60;

    default = 30;

    description = "Renew this many days before expiry";

  };

  alertDays = mkOption {

    type = types.ints.between 1 90;

    default = 14;

    description = "Alert if cert expires within N days";

  };

  certificates = mkOption {

    type = types.attrsOf (types.submodule {

      options = {

        domain = mkOption {

          type = types.nonEmptyStr;

        };

        altNames = mkOption {

          type = types.listOf types.nonEmptyStr;

          default = [];

        };

        provider = mkOption {

          type = types.enum [ "acme" "self-signed"

                              "internal-ca" ];

          default = "self-signed";

        };

        reloadServices = mkOption {

          type = types.listOf types.nonEmptyStr;

          default = [];

          description = "Services to reload after renewal";

        };

        keyType = mkOption {

          type = types.enum [ "rsa2048" "rsa4096"

                              "ec256" "ec384" ];

          default = "ec256";

        };

      };

    });

    default = {};

  };

};

Usage: Homelab Certificates

homelab.certs = {

  enable = true;

  acmeEmail = "admin@example.com";

  renewBeforeDays = 30;

  alertDays = 14;

  certificates = {

    grafana = {

      domain = "grafana.lan";

      provider = "internal-ca";

      reloadServices = [ "nginx" "grafana" ];

      keyType = "ec256";

    };

    vpn = {

      domain = "vpn.example.com";

      altNames = [ "wg.example.com" ];

      provider = "acme";

      reloadServices = [ "wireguard-wg0" ];

      keyType = "ec384";

    };

    monero-rpc = {

      domain = "monero.lan";

      provider = "self-signed";

      reloadServices = [ "monerod" ];

    };

  };

};

Error Scenarios

✗ ERROR: Invalid key type

certificates.grafana.keyType = "rsa1024";

error: The value "rsa1024" is not a valid value of type

'one of "rsa2048", "rsa4096", "ec256", "ec384"'.

⚠ RSA 1024-bit keys are cryptographically broken

CAs no longer issue 1024-bit certs (deprecated since 2013).

Modern browsers reject them outright.

The enum intentionally excludes insecure key sizes.

This is a security policy encoded in the type system.

✗ ERROR: Alert threshold absurdly low

homelab.certs.alertDays = 0;

error: not of type 'integer between 1 and 90'. Values: 0

⚠ alertDays=0 means you discover expiry AFTER it happens

Certificate expires at midnight. Your alert fires at midnight.

But the service is already rejecting connections.

Users saw the error before you did.

Minimum 1 day ensures you always have advance warning.

Recipe 6

Network Diagnostic Toolkit Module

Deploy diagnostic tools and scripts declaratively across all hosts

This recipe takes the diagnostic pipelines from the playbook and packages them as a Nix module. Instead of remembering which commands to run on which host, every host in your homelab gets the right diagnostic tools installed and the right scripts deployed based on its role.

Nix Option Declaration

options.homelab.diagnostics = {

  enable = mkOption {

    type = types.bool;

    default = true;

  };

  role = mkOption {

    type = types.enum [ "endpoint" "router" "dns" "monitor" ];

    description = ''

      endpoint: basic tools (ping, ss, dig)

      router: + tcpdump, conntrack, iptables logging

      dns: + DNS-specific probes and stats

      monitor: all tools + Prometheus-format exporters

    '';

  };

  extraPackages = mkOption {

    type = types.listOf types.package;

    default = [];

    description = "Additional diagnostic packages";

  };

  tracerouteMaxHops = mkOption {

    type = types.ints.between 1 64;

    default = 30;

  };

  captureInterface = mkOption {

    type = types.nullOr types.nonEmptyStr;

    default = null;

    description = "Default interface for tcpdump (null = any)";

  };

  captureMaxPackets = mkOption {

    type = types.ints.between 10 100000;

    default = 1000;

    description = "Max packets per capture session";

  };

};

Implementation: Role-Based Package Sets

The role enum drives which packages are installed. Each role is a superset of the previous, maintaining cohesion (tools match the host's function) and decoupling (the module doesn't know what services the host runs, only its network role).

# Implementation sketch

let

  basePkgs = with pkgs; [ iproute2 iputils dnsutils

    inetutils curl netcat-openbsd ];

  routerPkgs = basePkgs ++ (with pkgs; [

    tcpdump conntrack-tools iptables nftables

    ethtool bridge-utils ]);

  dnsPkgs = basePkgs ++ (with pkgs; [

    bind  # for dig +trace, delv

    whois  # domain expiry checks

    ldns   # drill command

  ]);

  monitorPkgs = routerPkgs ++ dnsPkgs ++ (with pkgs; [

    mtr nmap iperf3 bmon

  ]);

  rolePkgs = {

    endpoint = basePkgs;

    router   = routerPkgs;

    dns      = dnsPkgs;

    monitor  = monitorPkgs;

  };

in {

  environment.systemPackages =

    rolePkgs.${cfg.role} ++ cfg.extraPackages;

}

Usage: Per-Host Diagnostic Configuration

# hosts/pi-monero.nix

homelab.diagnostics = {

  role = "endpoint";  # minimal: ping, dig, ss, curl

};

# hosts/router.nix

homelab.diagnostics = {

  role = "router";

  captureInterface = "vlan20";  # default tcpdump target

  captureMaxPackets = 5000;

};

# hosts/pi-dns.nix

homelab.diagnostics = {

  role = "dns";

  extraPackages = [ pkgs.dogdns ];  # alternative to dig

};

# hosts/nuc.nix

homelab.diagnostics = {

  role = "monitor";  # gets everything

};

✗ ERROR: Invalid capture packet limit

homelab.diagnostics.captureMaxPackets = 5;

error: not of type 'integer between 10 and 100000'. Values: 5

⚠ 5 packets is too few for any meaningful analysis

tcpdump -c 5 captures 5 packets in milliseconds.

You can't see patterns, retransmissions, or trends.

Minimum 10 ensures at least one meaningful exchange.

Maximum 100000 prevents accidental multi-GB capture files.

Recipe 7

Secrets Management with sops-nix

Typed secret references, deployment paths, and access control

Secrets are the one configuration element that must never appear in the Nix store (which is world-readable). sops-nix solves this by encrypting secrets at rest and decrypting them at activation time. The type system here enforces that every secret has an owner, a group, permissions, and a file path that the consuming service can reference, without the secret's value ever touching the Nix evaluation.

Nix Option Declaration

options.homelab.secrets = {

  enable = mkOption {

    type = types.bool;

    default = false;

  };

  sopsFile = mkOption {

    type = types.path;

    description = "Path to the encrypted sops YAML file";

  };

  items = mkOption {

    type = types.attrsOf (types.submodule {

      options = {

        key = mkOption {

          type = types.nonEmptyStr;

          description = "Key in the sops YAML file";

        };

        owner = mkOption {

          type = types.nonEmptyStr;

          default = "root";

        };

        group = mkOption {

          type = types.nonEmptyStr;

          default = "root";

        };

        mode = mkOption {

          type = types.enum ["0400" "0440" "0600" "0640" "0644"];

          default = "0400";

          description = "File permissions (restricted set)";

        };

        restartUnits = mkOption {

          type = types.listOf types.nonEmptyStr;

          default = [];

          description = "systemd units to restart on change";

        };

      };

    });

    default = {};

  };

};

Usage: Homelab Secrets

# hosts/nuc.nix

homelab.secrets = {

  enable = true;

  sopsFile = ./secrets/nuc.yaml;

  items = {

    wireguard-key = {

      key = "wg_private_key";

      owner = "root";

      mode = "0400";  # only root reads private keys

      restartUnits = [ "wireguard-wg0" ];

    };

    grafana-admin = {

      key = "grafana_admin_password";

      owner = "grafana";

      group = "grafana";

      mode = "0440";  # grafana user + group can read

      restartUnits = [ "grafana" ];

    };

    backup-ssh-key = {

      key = "backup_ssh_key";

      mode = "0400";

    };

  };

};

✗ ERROR: Overly permissive mode

items.wireguard-key.mode = "0777";

error: The value "0777" is not a valid value of type

'one of "0400", "0440", "0600", "0640", "0644"'.

⚠ The enum IS the security policy

0777 means world-readable and world-writable.

Any process on the host can read your WireGuard private key.

The enum restricts to a safe set: read-only for owner,

optionally group-readable, never world-writable.

Security policy is enforced at build time, not by audit.

Master Reference: All Recipes by Domain

This table maps every recipe in both volumes to the infrastructure domain it serves, the primary types used, and the diagnostic pipeline that validates it.

Recipe

Domain

Key Types

Validation Pipeline

Vol1: Firewall

Security

listOf submodule, enum

iptables -L -v -n | awk

Vol1: WireGuard

VPN

attrsOf submodule, nullOr

wg show | grep handshake

Vol1: Collector

Monitoring

port, listOf, submodule

curl localhost:9100/metrics

R1: DNS

Name Resolution

attrsOf submodule, enum

dig +stats @resolver domain

R2: Backups

Data Protection

attrsOf submodule, enum, nullOr

stat -c %Y backup/latest

R3: Scheduling

Automation

attrsOf submodule, between

systemctl list-timers

R4: Logging

Observability

attrsOf submodule, between

du -sh /var/log/* | sort -hr

R5: Certs

TLS Lifecycle

attrsOf submodule, enum

openssl x509 -enddate

R6: Diagnostics

Troubleshooting

enum, nullOr, between

ss -tuln | awk + tcpdump

R7: Secrets

Security

attrsOf submodule, enum, path

stat -c %a /run/secrets/*

The Unifying Pattern Across All Recipes

Every recipe follows the same three-layer architecture: a bash pipeline that answers a diagnostic question (Layer 1), a Nix option module that declares what valid configuration looks like (Layer 2), and a set of types that prevent misconfiguration from reaching the network (Layer 3). The pipeline is the runtime validation. The types are the build-time validation. Together, they form a closed feedback loop where mistakes are caught at the earliest possible moment.

The cohesion principle: each module owns exactly one infrastructure concern (DNS, backups, certs, logging). The decoupling principle: modules communicate through typed options, never by reading each other's implementation. The replaceability principle: swap any module's implementation (bash scripts for Go exporters, self-signed for ACME, rsync for restic) and nothing downstream breaks because the typed interface stays the same.

Types don't just validate data. They encode architectural decisions, security policies, and domain knowledge into a form that the build system enforces automatically.
