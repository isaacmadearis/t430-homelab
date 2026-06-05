# ThinkPad T430 Hybrid Cloud Homelab

### My ThinkPad T430 Homelab Setup

An enterprise-grade personal cloud node built on legacy hardware, designed to test Linux System Administration, containerized networks, and AWS hybrid workflows.

## 🛠️ Getting Started

Clone the repo and run the setup script to bootstrap local dev tooling (shellcheck, GPG signing config):

```bash
git clone https://github.com/isaacmadearis/t430-homelab.git
cd t430-homelab
./scripts/setup.sh
```

Safe to re-run — skips anything already installed. Installs `shellcheck` to `~/.local/bin` without requiring sudo.

## 🚀 Architecture Overview
- **Host OS:** Ubuntu Server (Headless)
- **Control Plane:** CasaOS / Portainer (Docker Engines)
- **Network Services:** Samba (SMB) Protocol for cross-platform Network Attached Storage (NAS)

## 🛠️ Infrastructure Services

### 1. Cross-Platform File Sharing (Samba / SMB)
Successfully implemented a local NAS configuration allowing seamless file sharing across multiple device ecosystems (macOS, iOS, and Linux clients).
- **Configuration File:** Saved under `templates/smb.conf`
- **Security Control:** Integrated user-level authentication mapping to isolated homelab directories.

### 2. Containerization Engine
- Deployed Docker Engine for modular microservice delivery.
- Configured Portainer and CasaOS for deep-dive network auditing and resource visualization.
