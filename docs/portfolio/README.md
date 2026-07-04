# Portfolio Evidence Index

Visual proof of completed homelab infrastructure projects.
Images are scrubbed of secrets before commit — no tokens, passwords, or full Tailscale IPs.

---

| # | Project | Status | Evidence |
|---|---------|--------|----------|
| 01 | [Hardened Base OS](01-hardened-base-os/) | Complete | UFW ruleset, headless uptime |
| 02 | [WordPress + MySQL](02-wordpress-mysql/) | Complete | Live site, DB ready, network inspect |
| 03 | [Cloudflare Tunnel](03-cloudflare-tunnel/) | Complete | Tunnel healthy, public HTTPS padlock |
| 04 | [Caddy + DNS-01 TLS](04-caddy-dns01-tls/) | Complete | `casa.madearlabs.com` valid cert |
| 05 | [Tailscale Mesh](05-tailscale-mesh/) | Complete | 4-node status |
| 06 | [GPG Signing](06-gpg-signing/) | Complete | Pinentry prompt, signed log |
| 07 | [SSH Hardening](07-ssh-hardening/) | Pending | Key-only auth, UFW scoped to `tailscale0` |

---

> Each subfolder contains a `README.md` with captions and embedded screenshots.
> Drop images into the correct folder, then run:
> ```bash
> git add docs/portfolio/
> git commit -m "docs: add Phase N portfolio screenshots"
> git push origin main
> ```
