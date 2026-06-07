# Homelab Project Agenda
> Active sprint: Project 2 — Multi-Tier Web Framework Infrastructure

---

## Phase 1 — Data Tier Hardening (Immediate / Blocking)

- [x] **Remediate DLP violation** in `projects/wordpress-mysql/docker-compose.yml`
  - Move `MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD` out of the compose file and into an `.env` file
  - Confirm `.env` is present in `.gitignore` before committing
  - Replace inline values with `${VAR_NAME}` references

---

## Phase 2 — WordPress Presentation Layer (Next)

- [x] Add `wordpress:latest` service to the existing compose stack
- [x] Link WordPress to `wp_database` via `WORDPRESS_DB_*` environment variables (sourced from `.env`)
- [x] Mount a named volume `wp_data` for WordPress content persistence
- [x] Attach to `lab-isolated-net` (no host network exposure)
- [x] Validate end-to-end: MySQL ready → WordPress installer loads in browser

---

## Phase 3 — Ingress & Public Exposure (Upcoming)

- [x] Deploy containerized `cloudflared` as the outbound tunnel agent
- [x] Map public subdomain(s) via Cloudflare Zero Trust tunnel rules (`wp.madearlabs.com`)
- [x] Remove any direct UFW port exposure for WordPress (port 80/8080) once tunnel is live
- [x] Capture `docker network inspect lab-isolated-net` screenshot as network proof



---

## Phase 4 — CasaOS HTTPS via Caddy + Cloudflare DNS-01 (Status: Complete)
> CasaOS dashboard reachable over valid TLS at `https://casa.madearlabs.com`

- [x] Confirmed CasaOS reachable at `100.x.y.z` (Tailscale IP) on port 80
- [x] Added A record in Cloudflare: `casa.madearlabs.com` → `100.x.y.z` (DNS only, no proxy)
- [x] Installed Go (`golang-go`) and `xcaddy`
- [x] Compiled Caddy v2.11.4 with `caddy-dns/cloudflare` plugin via `xcaddy`
- [x] Moved binary to `/usr/local/bin/caddy`
- [x] Created `/etc/caddy/caddy.env` with Cloudflare API token (`chmod 600`)
- [x] Created `/etc/caddy/Caddyfile` with DNS-01 TLS config and `auto_https disable_redirects`
- [x] Created `/etc/systemd/system/caddy.service` with `EnvironmentFile` pointing to `caddy.env`
- [x] Let's Encrypt certificate issued successfully for `casa.madearlabs.com`
- [x] CasaOS now accessible at `https://casa.madearlabs.com` with valid padlock

---

## Phase 4.5 — Cloudflare Access 2FA Enforcement (Upcoming)
> Lock down `wp.madearlabs.com` and `casa.madearlabs.com` behind Cloudflare Access with mandatory Two-Factor Authentication

- [ ] **Cloudflare Zero Trust → Settings → Authentication**
  - Enable One-time PIN (OTP) or connect an identity provider (Google / GitHub) as the IdP
  - Enforce `Require MFA` at the IdP policy level
- [ ] **Create an Access Application for `wp.madearlabs.com`**
  - Type: Self-hosted
  - Domain: `wp.madearlabs.com`
  - Session duration: `24h` (or tighten to `1h` for stricter posture)
  - Policy: Allow → Rule: Emails ending in `@madearlabs.com` (or explicit email list)
  - Enable `Purpose Justification` if audit logging is desired
- [ ] **Create an Access Application for `casa.madearlabs.com`**
  - Same IdP and MFA requirement as above
  - Domain: `casa.madearlabs.com`
  - Restrict to the same trusted email list
- [ ] **Validate end-to-end login flow**
  - Browse to `https://wp.madearlabs.com` from a clean browser session — confirm Cloudflare Access login wall appears
  - Authenticate with IdP → confirm 2FA challenge fires (TOTP code or OTP email)
  - Confirm successful passthrough to WordPress/CasaOS behind the gate
  - Repeat for `https://casa.madearlabs.com`
- [ ] **Verify bypass is impossible**
  - Confirm direct container port is not reachable from the public internet (tunnel-only ingress)
  - Confirm Cloudflare proxy (orange cloud) is enabled on both DNS records

---

## Phase 5 — AWS Cloud Identity (Parked)

- [ ] Document LDAP bridge config between AWS AD DS (`isaaclab.local`) and Ubuntu osTicket node
- [ ] Validate Tailscale connectivity between AWS nodes and T430

---

## Phase 6 — Nextcloud Subdomain Deployment (`nextcloud.madearlabs.com`)

- [ ] Create a dedicated `projects/nextcloud/docker-compose.yml` stack
  - Use `nextcloud:latest` image with a persistent named volume (`nextcloud_data`)
  - Back with a `mariadb:10.11` (or `postgres:16`) data container and named volume (`nextcloud_db`)
  - Source all DB credentials from `.env` — no cleartext secrets in compose file
  - Attach both containers to `lab-isolated-net` as `external: true`
- [ ] Add Cloudflare Zero Trust tunnel rule mapping `nextcloud.madearlabs.com` → internal Nextcloud container port
- [ ] Harden Nextcloud config (`config/config.php`)
  - Set `'trusted_domains'` to include `nextcloud.madearlabs.com`
  - Set `'overwriteprotocol' => 'https'` and `'overwrite.cli.url'`
- [ ] Remove any direct UFW port exposure once tunnel is live
- [ ] Validate end-to-end: Nextcloud login page loads at `https://nextcloud.madearlabs.com`
- [ ] Capture `docker network inspect lab-isolated-net` screenshot as network proof



---

## Phase 7 — Notes Ingress (Upcoming)
> Self-hosted FOSS notes app (SilverBullet) exposed at `notes.madearlabs.com`

- [ ] Add a `silverbullet` service to the compose stack
      (`ghcr.io/silverbulletmd/silverbullet:latest`)
- [ ] Mount a named volume `sb_data` at `/space` for note/markdown persistence
- [ ] Attach to `lab-isolated-net` with **no host port exposure** (web UI on internal :3000)
- [ ] Set basic auth via `SB_USER` (`user:pass`) sourced from `.env` — no cleartext in Git
- [ ] Add public hostname `notes.madearlabs.com` → `http://silverbullet:3000`
      as a Cloudflare Zero Trust tunnel rule (reuse the existing `cf_tunnel` agent)
- [ ] Validate end-to-end: container healthy → `notes.madearlabs.com` loads over HTTPS

---

## Standing Maintenance Checklist

- [ ] GPG signing active: `export GPG_TTY=$(tty)` before any commit session over SSH
- [ ] Confirm all new stacks join `lab-isolated-net` as `external: true`
- [ ] No cleartext secrets in any Git-tracked file
