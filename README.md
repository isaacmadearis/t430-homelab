# My ThinkPad T430 Homelab Setup
# ThinkPad T430 Hybrid Cloud Homelab

An enterprise-grade personal cloud node built on legacy hardware, designed to test Linux System Administration, containerized networks, and AWS hybrid workflows.

## 🚀 Architecture Overview
- [cite_start]**Host OS:** Ubuntu Server (Headless) [cite: 7, 9]
- [cite_start]**Control Plane:** CasaOS / Portainer (Docker Engines) [cite: 15, 16, 17]
- **Network Services:** Samba (SMB) Protocol for cross-platform Network Attached Storage (NAS)

## 🛠️ Infrastructure Services

### 1. Cross-Platform File Sharing (Samba / SMB)
Successfully implemented a local NAS configuration allowing seamless file sharing across multiple device ecosystems (macOS, iOS, and Linux clients).
- **Configuration File:** Saved under `templates/smb.conf`
- **Security Control:** Integrated user-level authentication mapping to isolated homelab directories.

### 2. Containerization Engine
- [cite_start]Deployed Docker Engine for modular microservice delivery[cite: 15].
- [cite_start]Configured Portainer and CasaOS for deep-dive network auditing and resource visualization[cite: 16, 17].
