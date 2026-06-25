# Docker At Home

Self-hosted Docker stack for home services, organised by functional profiles.

## 📁 Architecture

A single `docker-compose.yml` uses **profiles** to group services by category:

- **infrastructure** — Core services (Traefik, OMV-Proxy, Portainer, Authentik, Homepage, Glances, CrowdSec)
- **dashboard** — Dashboards (Homepage)
- **media** — Media stack (Jellyfin, Jellyseerr, Radarr, Sonarr, Prowlarr, qBittorrent + Gluetun VPN, Jellystat, Ygège)
- **devtools** — Developer tools (SonarQube, Authentik)
- **domotique** — Home automation (Home Assistant)
- **security** — Security (CrowdSec)
- **tools** — Misc tools (RSSHub, FreshRSS)
- **all** — Every service

> The PostgreSQL databases (Authentik, Jellystat, SonarQube) start automatically with their parent service and are not listed individually.

## 🚀 Quick start

1. **Configuration**

   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

2. **Start everything**

   ```bash
   docker compose --profile all up -d
   ```

3. **Start a specific profile**

   ```bash
   # Infrastructure first (required)
   docker compose --profile infrastructure up -d

   # Then other profiles as needed
   docker compose --profile media up -d
   docker compose --profile domotique up -d
   ```

4. **Start several profiles at once**

   ```bash
   docker compose --profile infrastructure --profile media --profile domotique up -d
   ```

## 🛠️ Management

```bash
# Stop everything
docker compose --profile all down

# Stop a specific profile
docker compose --profile media down

# Follow a service's logs
docker compose logs -f [service]

# Follow a profile's logs
docker compose --profile media logs -f

# Restart a service
docker compose restart [service]

# Restart a profile
docker compose --profile media restart
```

## ⚙️ Services

### 🏗️ infrastructure

- **Traefik** — Reverse proxy with automatic SSL (Let's Encrypt)
- **OMV-Proxy** — nginx proxy exposing OpenMediaVault through Traefik
- **Portainer** — Docker management UI (OIDC SSO via Authentik)
- **Authentik** — SSO / Identity Provider (OIDC, OAuth2, Forward Auth), with a dedicated PostgreSQL (also in `devtools`)
- **Homepage** — Main landing dashboard, protected by Authentik Forward Auth (also in `dashboard`)
- **Glances** — Real-time system monitoring.
- **CrowdSec** — Intrusion detection engine; feeds the Traefik bouncer middleware (also in `security`)

### 📊 dashboard

- **Homepage** — Lightweight dashboard with customisable widgets, protected by Authentik SSO

### 🎬 media

- **Jellyfin** — Media streaming server (open-source Plex alternative)
- **Jellyseerr** — Media request interface for Jellyfin
- **Radarr** — Movie download/organisation automation
- **Sonarr** — TV show download/organisation automation
- **Prowlarr** — Indexer manager for Radarr/Sonarr
- **qBittorrent** — Torrent client with web UI; all traffic routed through the Gluetun VPN
- **Gluetun** — VPN client (WireGuard) tunnelling qBittorrent traffic
- **gluetun-qbt-watchdog** — Syncs Gluetun's forwarded port into qBittorrent and restarts qBittorrent when the VPN tunnel drops ([brunoorsolon/gluetun-qbt-watchdog](https://github.com/brunoorsolon/gluetun-qbt-watchdog))
- **Jellystat** — Usage statistics dashboard for Jellyfin (dedicated PostgreSQL)
- **Ygège** — YGGtorrent indexer proxy (consumed by Prowlarr)

### 🧰 devtools

- **SonarQube** — Code quality / static analysis (dedicated PostgreSQL)
- **Authentik** — see _infrastructure_

### 🏠 domotique

- **Home Assistant** — Home automation hub (host network, ZHA/Zigbee support)

### 🛡️ security

- **CrowdSec** — Behaviour-based intrusion detection; the Traefik bouncer middleware blocks flagged IPs

### 🧪 tools

- **RSSHub** — RSS feed generator for sites that don't provide one
- **FreshRSS** — Self-hosted RSS aggregator (OIDC SSO via Authentik)

## 📂 Media layout

The media stack uses a unified layout under `${MEDIA_PATH}`:

```
/srv/.../media/
├── downloads/          # qBittorrent downloads
│   ├── movies/         # Movies in progress
│   └── tv/             # TV in progress
├── movies/             # Movie library (Jellyfin)
└── tv/                 # TV library (Jellyfin)
```

**Recommended configuration**:

- Radarr → root folder: `/data/movies`
- Sonarr → root folder: `/data/tv`
- qBittorrent → downloads: `/data/downloads`
- Jellyfin → libraries: `/data/movies` and `/data/tv`

## 🔐 SSO with Authentik

**Authentik** is an open-source Identity Provider (IdP) providing single sign-on for the stack. It supports several protocols:

- **OIDC** (OpenID Connect) — for apps with native support
- **OAuth2** — for modern apps
- **SAML** — for enterprise apps
- **Forward Auth** — for apps without native SSO, via Traefik's `forwardauth` middleware and Authentik's embedded outpost

### Forward Auth (via Traefik → embedded outpost)

The following services are gated by Authentik Forward Auth. Each one has a dedicated **`<service>-access` group** that controls who may reach it (a user must belong to the group):

`homepage`, `omv`, `radarr`, `sonarr`, `prowlarr`, `qbittorrent`, `jellystat`, `glances`

The Traefik middlewares all point at the embedded outpost:

```
http://authentik-server:9000/outpost.goauthentik.io/auth/traefik
```

> **Arr services**: Radarr, Sonarr and Prowlarr have their internal auth disabled (`<AuthenticationMethod>External</AuthenticationMethod>` in `config.xml`) and rely entirely on Authentik for their **web UI**. If Authentik is down the UI is **unreachable** (502/503) but **secured**.

### API routes outside Authentik

For native API clients (Prowlarr ↔ Arr sync, Jellyseerr, Helmarr-style tooling, Terraform, …), the Forward Auth would block the request since it carries an API key, not an Authentik session. A dedicated higher-priority router therefore exposes the API path of each service **bypassing Authentik** (CrowdSec is still applied):

| Service     | Router            | Rule                                      | Auth on the API                  |
| ----------- | ----------------- | ----------------------------------------- | -------------------------------- |
| Radarr      | `radarr-api`      | `Host(radarr.…) && PathPrefix(/api)`      | `X-Api-Key`                      |
| Sonarr      | `sonarr-api`      | `Host(sonarr.…) && PathPrefix(/api)`      | `X-Api-Key`                      |
| Prowlarr    | `prowlarr-api`    | `Host(prowlarr.…) && PathPrefix(/api)`    | `X-Api-Key`                      |
| qBittorrent | `qbittorrent-api` | `Host(qbt.…) && PathPrefix(/api/v2)`      | qBittorrent WebUI auth (re-enabled) |
| Jellystat   | `jellystat-api`   | `Host(jellystat.…) && PathPrefix(/api)`   | `x-api-token`                    |

> These routers use `priority=100` so the `/api` prefix wins over the catch-all UI router. The API stays reachable even when Authentik is down — each service authenticates the request itself (API key / token). For qBittorrent this requires its WebUI auth to be **re-enabled** (it is no longer fronted by Authentik on `/api/v2`).

### Native OIDC

- **Portainer** — OIDC (Authentik side managed by Terraform; the OAuth fields are entered manually in Portainer's UI, see below)
- **FreshRSS** — OIDC (fully managed by Terraform, credentials injected via env file)
- **Jellyfin** — OIDC via the SSO plugin (manual)

### Access

- **URL**: `https://auth.${DOMAIN_BASE}`
- **Bootstrap admin**: set via `AUTHENTIK_BOOTSTRAP_EMAIL` and `AUTHENTIK_BOOTSTRAP_PASSWORD` in `.env`

### Portainer OIDC — UI configuration

Portainer does not read OIDC settings from environment variables, so the OAuth section must be filled in its web UI. Terraform creates the Authentik provider/application and writes the endpoints to `terraform/authentik/generated/portainer.env` for reference.

In Portainer → **Settings → Authentication → OAuth**:

| Field              | Value                                                              |
| ------------------ | ------------------------------------------------------------------ |
| Provider           | Custom                                                             |
| Client ID / Secret | from Authentik (see `generated/portainer.env`)                     |
| Authorization URL  | `https://auth.${DOMAIN_BASE}/application/o/authorize/`             |
| Access token URL   | `https://auth.${DOMAIN_BASE}/application/o/token/`                 |
| Resource URL       | `https://auth.${DOMAIN_BASE}/application/o/userinfo/`              |
| Logout URL         | `https://auth.${DOMAIN_BASE}/application/o/portainer/end-session/` |
| Redirect URL       | `https://portainer.${DOMAIN_BASE}/`                                |
| User identifier    | `preferred_username` (or `email`)                                  |
| Scopes             | `email openid profile`                                             |

## 🧬 Infrastructure as Code (Terraform)

Two independent Terraform modules under `terraform/` keep the stack reproducible across servers:

- `terraform/authentik/` — Authentik SSO (provider `goauthentik/authentik`)
- `terraform/arr/` — Radarr / Sonarr / Prowlarr configuration (providers `devopsarr/{radarr,sonarr,prowlarr}`)

### `terraform/authentik/`

The Authentik configuration is managed as code (provider `goauthentik/authentik`).

| File                                               | Purpose                                                                                                                                                                         |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `providers.tf`, `variables.tf`, `terraform.tfvars` | Provider + connection (Authentik URL & API token)                                                                                                                               |
| `shared.tf`                                        | Shared data sources (authorization/invalidation flows, default OIDC scopes)                                                                                                     |
| `freshrss.tf`, `portainer.tf`                      | OIDC providers + applications (+ generated env file)                                                                                                                            |
| `proxy_forwardauth.tf`                             | The 8 Forward Auth services: per service a proxy provider (`forward_single`), an application, a `<service>-access` group, and a policy binding restricting access to that group |
| `outpost.tf`                                       | Embedded outpost; all proxy providers are attached automatically                                                                                                                |

The embedded outpost is a pre-existing singleton: `outpost.tf` adopts it automatically through an `import` block (requires **Terraform ≥ 1.6**), so no manual `terraform import` is needed on a fresh server.

**Usage**:

```bash
cd terraform/authentik
# set authentik_url and authentik_token in terraform.tfvars
terraform init
terraform plan
terraform apply
```

> After `apply`, add your user to the relevant **`<service>-access`** groups — otherwise Forward Auth will deny access since the policy binding requires group membership.

### `terraform/arr/`

This module codifies the Radarr / Sonarr / Prowlarr configuration (quality settings, indexers, download clients, notifications) so a fresh server lands on the same tuned setup. It talks to each service over its **internal** URL (container name on `traefik_net`) authenticated by API key, never the public Traefik URL. Requires **Terraform ≥ 1.7** (conditional `import` blocks with `for_each`).

| File                     | Purpose                                                                                                                                                       |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `providers.tf`, `variables.tf`, `terraform.tfvars` | Providers + connection (URLs, API keys, qBittorrent, Telegram, paths)                                                               |
| `locals.tf`              | Shared TRaSH-style **custom formats** (FR language favoured: MULTi/TRUEFRENCH/FRENCH; VOSTFR/VFQ/unwanted blocked) with per-resolution scores (1080p / 2160p) |
| `radarr.tf`, `sonarr.tf` | Root folder, qBittorrent download client, custom formats, quality profiles, recycle bin                                                                       |
| `prowlarr.tf`            | qBittorrent download client, Radarr/Sonarr applications (category sync), Telegram notification                                                                 |
| `indexers.tf`            | Prowlarr Cardigann indexers (Ygégé, Generation-Free, Nostradamus, Torr9, C411) — created in Prowlarr then **adopted by import**                                |
| `sync_profile.tf`        | Prowlarr sync profiles with a per-indexer **minimum-seeders floor** (Ygégé/Leak = 2)                                                                           |
| `quality_definitions.tf` | TRaSH quality sizes (`min_size = 0` so size never blocks; custom formats do the filtering)                                                                     |
| `imports.tf`             | Conditional imports — empty `*_import_id` ⇒ resource **created** (fresh server); set ⇒ existing Arr config **adopted**                                          |

**Usage**:

```bash
cd terraform/arr
cp terraform.tfvars.example terraform.tfvars
# fill in API keys (config.xml -> <ApiKey>), qBittorrent + Telegram creds, paths
terraform init
terraform plan
terraform apply
```

> **Adopting an existing setup**: on a server where Radarr/Sonarr/Prowlarr are already configured, fill the `*_import_id` / `indexer_import_ids` values in `terraform.tfvars` so Terraform adopts the existing resources instead of creating duplicates. Leave them empty on a fresh server.

## 🔒 Security notes

- ✅ Centralised authentication, unified users/groups, native 2FA/MFA, centralised auth logs
- ✅ CrowdSec + Traefik bouncer block malicious IPs at the edge
- ⚠️ **Single point of failure**: if Authentik is down, every Forward Auth / OIDC **web UI** becomes inaccessible (the `/api` routes stay up — see below)
- ⚠️ Arr **web UIs** (`AuthenticationMethod=External`) have **no protection of their own** without Authentik
- ⚠️ The `/api` routes (Radarr, Sonarr, Prowlarr, qBittorrent, Jellystat) **bypass Authentik** and are guarded only by CrowdSec + the service's own API key / token. Keep those keys secret and qBittorrent's WebUI auth enabled.

**Recommendations**:

1. Monitor Authentik (a healthcheck is configured)
2. Back up the PostgreSQL databases regularly
3. Alert on Authentik downtime
4. Periodically test a full-stack startup

### Disabling internal auth on Arr services

Internal auth is disabled by editing `config.xml` directly (not available via environment variables):

```xml
<AuthenticationMethod>External</AuthenticationMethod>
```

**Procedure**:

1. Stop the containers: `docker compose stop radarr sonarr prowlarr`
2. Edit the `config.xml` files in the Docker volumes
3. Start them again: `docker compose start radarr sonarr prowlarr`
