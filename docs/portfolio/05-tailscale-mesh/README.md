# 05 — Tailscale Mesh VPN

**Topology:** Flat encrypted mesh over cellular/WAN — four nodes connected via `100.x.y.z` CGNAT range.
Remote mobile system triage validated via Termius (iPhone 15 Pro → T430).

---

## Evidence

### Four-Node Status
> Command: `tailscale status`
> Expected: all four nodes listed as connected — `t430-server`, `macbook-pro`, `mac-mini`, `iphone-15-pro`.
> Scrub: mask full `100.x.y.z` IPs to `100.x.y.z` format as shown in project docs.

<!-- Drop screenshot here and update the filename -->
![Tailscale status four nodes](tailscale-status-four-nodes.png)
