# Aliases & Services Reference

Quick-access aliases and system service diagnostics.

---

## Service Status & System Monitoring

System services are configured in `hosts/alice/`. Quick access aliases:

**System Services:**
```bash
'svc-ssh': 'systemctl status sshd',          # SSH server
'svc-ssh-start': 'sudo systemctl start sshd',
'svc-ssh-stop': 'sudo systemctl stop sshd',
'svc-fail2ban': 'systemctl status fail2ban', # Intrusion prevention
'svc-pipewire': 'systemctl status pipewire.service',  # Audio server
```

**System Diagnostics:**
```bash
'sys-power': 'acpi -b',                      # Battery/power status
'sys-audio': 'pactl list sinks',             # Audio device info
'sys-usb': 'lsusb',                          # USB devices
'sys-disk': 'df -h',                         # Disk usage
'sys-network': 'nmcli device status',        # Network status
'sys-temps': 'sensors 2>/dev/null || echo "Install lm_sensors"',  # CPU temps
'sys-procs': 'ps aux | head -20',            # Top processes
'sys-logs': 'journalctl -n 20 --no-pager',   # Recent system logs
```

---

## Design Trade-offs

### Why Some Tools Don't Have Aliases

**GUI Applications**
- Better launched via `menu` (Rofi)
- Reduces CLI clutter
- Easier discoverability for users

**Specialized Tools** (jq, yq, sops, imagemagick)
- Used infrequently
- Syntax varies by use case
- Alias would be less clear than full command

**System Diagnostics** (xprop, xdotool, acpi)
- Advanced/expert tools
- Not used in daily workflow
- CLI is descriptive enough

---

## Aliases vs System Configuration

System config lives in `hosts/alice/`, aliases are for quick diagnostics:

| Feature | System Config | Quick Alias | Use Case |
|---------|---|---|---|
| Audio | `services.pipewire` | `sys-audio` | Verify setup vs diagnose issue |
| Network | `networking.networkmanager` | `sys-network` | Check config vs check status |
| Power | `powerManagement.powertop` | `sys-power` | Enabled vs current battery |
| Thermal | `services.thermald` | `sys-temps` | Background service vs quick check |

---

## Future Integrations

**Database Connections** (when added):
```bash
# PostgreSQL example:
'psql-local': 'psql -U postgres -h localhost',

# Redis example:
'redis-cli': 'redis-cli -h localhost',
```

**VPN/Mesh Management:**
- Tailscale: Already enabled in `services.tailscale`
