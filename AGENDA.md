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

## Phase 5 — Nextcloud Subdomain Deployment (`nextcloud.Madearlabs.com`)

- [ ] Create a dedicated `projects/nextcloud/docker-compose.yml` stack
  - Use `nextcloud:latest` image with a persistent named volume (`nextcloud_data`)
  - Back with a `mariadb:10.11` (or `postgres:16`) data container and named volume (`nextcloud_db`)
  - Source all DB credentials from `.env` — no cleartext secrets in compose file
  - Attach both containers to `lab-isolated-net` as `external: true`
- [ ] Add Cloudflare Zero Trust tunnel rule mapping `nextcloud.Madearlabs.com` → internal Nextcloud container port
- [ ] Harden Nextcloud config (`config/config.php`)
  - Set `'trusted_domains'` to include `nextcloud.Madearlabs.com`
  - Set `'overwriteprotocol' => 'https'` and `'overwrite.cli.url'`
- [ ] Remove any direct UFW port exposure once tunnel is live
- [ ] Validate end-to-end: Nextcloud login page loads at `https://nextcloud.Madearlabs.com`
- [ ] Capture `docker network inspect lab-isolated-net` screenshot as network proof

---

## Phase 4 — AWS Cloud Identity (Parked)

- [ ] Document LDAP bridge config between AWS AD DS (`isaaclab.local`) and Ubuntu osTicket node
- [ ] Validate Tailscale connectivity between AWS nodes and T430

---

## Standing Maintenance Checklist

- [ ] GPG signing active: `export GPG_TTY=$(tty)` before any commit session over SSH
- [ ] Confirm all new stacks join `lab-isolated-net` as `external: true`
- [ ] No cleartext secrets in any Git-tracked file
