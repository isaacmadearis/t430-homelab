# 🌐 Isaac's Homelab & Public Cloud Infrastructure Contract

This repository documents the bare-metal, containerized, and hybrid-cloud infrastructure for System Engineer Isaac Madearis. Follow these architectural boundaries implicitly. Do not guess commands.

> **Assistant behavior & engineering rules:** see @.github/claude-instructions.md

---

## 🛠️ The Tech Stack Environment Context
- **Host Hardware:** Headless Lenovo ThinkPad T430 Server node (Ubuntu Server LTS).
- **Remote Access Layer:** Flat encrypted Tailscale Mesh VPN over cellular/WAN (`100.x.y.z` CGNAT range).
- **Container Engine:** Docker Engine + Docker Compose (Managed via CasaOS web GUI and Portainer CE).
- **Public Cloud Tier:** AWS Free Tier (Windows Server 2022 AD DS forest `isaaclab.local` & Ubuntu osTicket node).

---

## 🛡️ Critical Operational Guardrails (Read Before Execution)
1. **Network Boundary Isolation:** All containerized applications MUST be plumbed into the pre-existing user-defined external bridge network named `lab-isolated-net`. Never declare an isolated app directly on the default host network.
2. **Production Zero-Interference Policy:** The host server operates in a shared residential space alongside critical work-from-home operations. Network interruptions, accidental LAN DHCP collisions, or broadcast leaks are strictly prohibited.
3. **Hardware Constraints:** The T430 utilizes an older, reliable Intel CPU without a dedicated hardware-accelerated GPU. Minimize intensive native CPU compute spikes. 

---

## 💻 Git & Code Quality Automation Workflows
- **Commit Message Convention:** Follow the strict Conventional Commits standard (e.g., `feat:`, `fix:`, `docs:`, `chore:`).
- **Cryptographic Integrity:** Automatic GPG code-signing is globally enforced on this machine (`commit.gpgsign=true`). Ensure your environment handles pinentry hooks elegantly over active SSH streams.

---

## 🚀 Active Project Manifest
### Project 1: Hardened Base OS Setup (Status: Complete)
- ACPI target overridden to allow persistent 24/7 headless clamshell monitoring. Edge firewall restricted to UFW explicit rule sets (`22/tcp`, `80/tcp`, `8080/tcp`).

### Project 2: Multi-Tier Decoupled Web Ingress (Status: Config Prepped / Pending Deployment)
- **Target:** Presentation layer (`wordpress:latest`) linked to data layer (`mysql:8.0`).
- **Data Blueprint:** Utilize declarative Infrastructure-as-Code via Docker Compose with persistent anonymous or named volume blocks (`db_data`, `wp_data`). 

### Project 3: AWS Cloud Identity Ecosystem (Status: Documentation Blueprint Completed)
- Remote LDAP bridging between AWS Windows AD DS and localized Ubuntu helpdesk nodes.

### Project 4: Tailscale Transport Layer (Status: Verified Active)
- Connected: `t430-server`, `macbook-pro`, `mac-mini`, and `iphone-15-pro`. Verified remote mobile system triage using Termius.

### Future Target: Cloudflare Reverse Tunnels (Status: Planned)
- Ingress mapping to route public subdomains safely via containerized `cloudflared` outbound connections to hide server ports entirely.
