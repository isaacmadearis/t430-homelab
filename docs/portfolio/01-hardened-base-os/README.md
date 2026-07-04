# 01 — Hardened Base OS

**Host:** Lenovo ThinkPad T430 — Ubuntu Server LTS, headless 24/7 clamshell mode.
ACPI target overridden; edge firewall restricted to explicit UFW rules.

---

## Evidence

### UFW Ruleset
> Command: `sudo ufw status verbose`
> Expected: `22/tcp` open anywhere, `80/tcp` scoped to `100.64.0.0/10` (Tailscale CGNAT), default deny incoming.

<!-- Drop screenshot here and update the filename -->
![UFW ruleset](ufw-status-verbose.png)

---

### Headless Uptime
> Command: `uptime`
> Expected: continuous runtime confirming persistent headless operation.

<!-- Drop screenshot here and update the filename -->
![Headless uptime](headless-uptime.png)
