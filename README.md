# Docker At Home

Self-hosted Docker stack for home services, organised by functional profiles.

## 📁 Architecture

A single `docker-compose.yml` uses **profiles** to group services:

- **infrastructure** — Traefik, Tailscale, Portainer, Authentik, Homepage, CrowdSec
- **dashboard** — Homepage
- **media** — Jellyfin, Seerr, Radarr, Sonarr, Prowlarr, qBittorrent + Gluetun, Jellystat, Ygégé
- **devtools** — SonarQube, Authentik
- **security** — CrowdSec
- **tools** — RSSHub, FreshRSS, Papra
- **all** — Every service

> The PostgreSQL databases (Authentik, Jellystat, SonarQube) start with their parent service.

### 🌐 Public vs private (Tailscale)

Only **Jellyfin**, **Seerr**, **Authentik** and **FreshRSS** are public (`*.${DOMAIN_BASE}`, CrowdSec in front). Everything else lives on `*.lan.${DOMAIN_BASE}`, reachable only through the tailnet: a Tailscale sidecar shares Traefik's network namespace, so the node's `100.x` IP exposes Traefik `:443` to authorized devices. TLS uses a Let's Encrypt DNS-01 wildcard (OVH provider), and Authentik SSO (Forward Auth, or native OIDC where supported) stays on the private UIs as defense-in-depth. Full design, DNS plan and rollback: [`docs/acces-prive-tailscale.md`](docs/acces-prive-tailscale.md).

## 🚀 Quick start

1. **Configuration**

   ```bash
   cp .env.example .env
   ```

2. **Start everything**

   ```bash
   docker compose --profile all up -d
   ```

3. **Start a specific profile** (infrastructure first)

   ```bash
   docker compose --profile infrastructure up -d
   docker compose --profile media up -d
   ```

4. **Start several profiles at once**

   ```bash
   docker compose --profile infrastructure --profile media --profile tools up -d
   ```

## 🛠️ Management

```bash
docker compose --profile all down
docker compose --profile media down

docker compose logs -f [service]
docker compose --profile media logs -f

docker compose restart [service]
docker compose --profile media restart
```

## ⚙️ Services

### 🏗️ infrastructure

- **Traefik** — Reverse proxy with automatic SSL (Let's Encrypt, DNS-01 via OVH)
- **Tailscale** — Sidecar node `dah-proxy` sharing Traefik's netns; entry point of the private zone
- **Portainer** — Docker management UI (OIDC SSO via Authentik)
- **Authentik** — SSO / Identity Provider (OIDC, OAuth2, Forward Auth), dedicated PostgreSQL
- **Authentik Worker** — Drains Authentik's task queue (blueprints, outposts, emails, certificates); without it the queue is never consumed
- **Homepage** — Landing dashboard on `lan.${DOMAIN_BASE}`, native OIDC login against Authentik
- **CrowdSec** — Intrusion detection; feeds the Traefik bouncer middleware on the public routers

### 📊 dashboard

- **Homepage** — Dashboard with customisable widgets, protected by Authentik SSO

### 🎬 media

- **Jellyfin** — Media streaming server
- **Jellyseerr** — Media request interface for Jellyfin
- **Radarr** — Movie automation
- **Sonarr** — TV show automation
- **Prowlarr** — Indexer manager for Radarr/Sonarr
- **qBittorrent** — Torrent client, all traffic routed through Gluetun
- **Gluetun** — VPN client (WireGuard)
- **gluetun-qbt-watchdog** — Syncs Gluetun's forwarded port into qBittorrent and restarts it when the tunnel drops ([brunoorsolon/gluetun-qbt-watchdog](https://github.com/brunoorsolon/gluetun-qbt-watchdog))
- **Jellystat** — Usage statistics for Jellyfin (dedicated PostgreSQL)
- **Ygégé** — YGGtorrent indexer proxy (consumed by Prowlarr)
- **iSponsorBlockTV** — Skips/mutes YouTube ads and SponsorBlock segments on the Apple TV via the Lounge API ([dmunozv04/iSponsorBlockTV](https://github.com/dmunozv04/iSponsorBlockTV))

### 🧰 devtools

- **SonarQube** — Code quality / static analysis (dedicated PostgreSQL)
- **Authentik** — see _infrastructure_

### 🛡️ security

- **CrowdSec** — Behaviour-based intrusion detection; blocks flagged IPs on the public routers (jellyfin/seerr/auth/rss)

### 🧪 tools

- **RSSHub** — RSS feed generator for sites that don't provide one
- **FreshRSS** — RSS aggregator (OIDC SSO via Authentik)
- **Papra** — Document management on `doc.lan.${DOMAIN_BASE}` (OIDC SSO via Authentik)

## 📂 Media layout

Unified layout under `${MEDIA_PATH}`:

```
/srv/.../media/
├── downloads/
│   ├── movies/
│   └── tv/
├── movies/
└── tv/
```

**Recommended configuration**:

- Radarr → root folder: `/data/movies`
- Sonarr → root folder: `/data/tv`
- qBittorrent → downloads: `/data/downloads`
- Jellyfin → libraries: `/data/movies` and `/data/tv`

## 📺 iSponsorBlockTV (Apple TV pairing)

Pairing is required before the daemon can run — it exits while `devices` is empty. Auto-discovery (`--net=host`) is Linux-only, so pairing uses a TV code.

1. On the Apple TV: **YouTube app → Settings → Link with TV code** (leave that screen open).
2. On the Mac, run the wizard and paste the code:

```bash
docker compose run --rm isponsorblocktv setup-cli
```

3. Answer `n` to the API-key and channel-whitelist questions (whitelisting is the only feature needing a YouTube Data API key), then start it:

```bash
docker compose --profile media up -d isponsorblocktv
```

Settings live in `isponsorblocktv/config.json` (gitignored — it holds the pairing `screen_id`). Defaults: `mute_ads` and `skip_ads` enabled, SponsorBlock categories `sponsor`, `selfpromo`, `interaction`, `music_offtopic`. Also available: `intro`, `outro`, `preview`, `filler`, `hook`, `exclusive_access`.

Notes:

- YouTube rotates the pairing code format and revokes old `screen_id`s; re-run the wizard if skipping stops working. A warning is logged for the old 26-character format.
- Ad muting does not work when the Apple TV audio goes to a speaker over AirPlay.
- The first unskippable seconds of an ad still play (muted).

## 🔐 SSO with Authentik

**Authentik** provides single sign-on for the stack:

- **OIDC** — for apps with native support
- **OAuth2** — for modern apps
- **SAML** — for enterprise apps
- **Forward Auth** — for apps without native SSO, via Traefik's `forwardauth` middleware

### Forward Auth (via Traefik → embedded outpost)

Gated on their private hostnames (`*.lan.${DOMAIN_BASE}`), each behind a dedicated **`<service>-access` group**:

`radarr`, `sonarr`, `prowlarr`, `qbittorrent`, `jellystat`, `glances`, `changedetection`

> **Homepage** left this list: since v2.0 it authenticates on its own (`HOMEPAGE_AUTH_ENABLED` + `HOMEPAGE_OIDC_*`), so it uses a regular OIDC provider (`homepage.tf`) instead of the outpost. Access is still gated on the `homepage-access` group.

The Traefik middlewares all point at the embedded outpost:

```
http://authentik-server:9000/outpost.goauthentik.io/auth/traefik
```

> **Arr services**: Radarr, Sonarr and Prowlarr have their internal auth disabled (`<AuthenticationMethod>External</AuthenticationMethod>`) and rely entirely on Authentik for their **web UI**. If Authentik is down the UI is unreachable but secured.

### API routes outside Authentik

API clients send an API key, not an Authentik session, so Forward Auth would block them. A higher-priority router exposes each service's API path bypassing Authentik, on the private hostname:

| Service     | Router            | Rule                                          | Auth on the API                     |
| ----------- | ----------------- | --------------------------------------------- | ----------------------------------- |
| Radarr      | `radarr-api`      | `Host(radarr.lan.…) && PathPrefix(/api)`      | `X-Api-Key`                         |
| Sonarr      | `sonarr-api`      | `Host(sonarr.lan.…) && PathPrefix(/api)`      | `X-Api-Key`                         |
| Prowlarr    | `prowlarr-api`    | `Host(prowlarr.lan.…) && PathPrefix(/api)`    | `X-Api-Key`                         |
| qBittorrent | `qbittorrent-api` | `Host(qbt.lan.…) && PathPrefix(/api/v2)`      | qBittorrent WebUI auth (re-enabled) |
| Jellystat   | `jellystat-api`   | `Host(jellystat.lan.…) && PathPrefix(/api)`   | `x-api-token`                       |

> `priority=100` makes the `/api` prefix win over the catch-all UI router. These routes stay reachable when Authentik is down. qBittorrent therefore needs its WebUI auth **enabled**.

### Native OIDC

- **Portainer** — OIDC (Authentik side managed by Terraform, OAuth fields entered in Portainer's UI, see below)
- **FreshRSS** — OIDC (fully managed by Terraform, credentials injected via env file)
- **Papra** — OIDC (fully managed by Terraform; email/password login disabled)
- **Jellyfin** — OIDC via the SSO plugin (manual)

### Access

- **URL**: `https://auth.${DOMAIN_BASE}`
- **Bootstrap admin**: `AUTHENTIK_BOOTSTRAP_EMAIL` / `AUTHENTIK_BOOTSTRAP_PASSWORD` in `.env`

### Portainer OIDC — UI configuration

Portainer does not read OIDC settings from environment variables. Terraform creates the Authentik provider/application and writes the endpoints to `terraform/authentik/generated/portainer.env`.

In Portainer → **Settings → Authentication → OAuth**:

| Field              | Value                                                              |
| ------------------ | ------------------------------------------------------------------ |
| Provider           | Custom                                                             |
| Client ID / Secret | from Authentik (see `generated/portainer.env`)                     |
| Authorization URL  | `https://auth.${DOMAIN_BASE}/application/o/authorize/`             |
| Access token URL   | `https://auth.${DOMAIN_BASE}/application/o/token/`                 |
| Resource URL       | `https://auth.${DOMAIN_BASE}/application/o/userinfo/`              |
| Logout URL         | `https://auth.${DOMAIN_BASE}/application/o/portainer/end-session/` |
| Redirect URL       | `https://portainer.lan.${DOMAIN_BASE}/`                            |
| User identifier    | `preferred_username` (or `email`)                                  |
| Scopes             | `email openid profile`                                             |

## 🧬 Infrastructure as Code (Terraform)

Two independent modules under `terraform/`:

- `terraform/authentik/` — Authentik SSO (provider `goauthentik/authentik`)
- `terraform/arr/` — Radarr / Sonarr / Prowlarr (providers `devopsarr/{radarr,sonarr,prowlarr}`)

### `terraform/authentik/`

| File                                               | Purpose                                                                                                                                                                         |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `providers.tf`, `variables.tf`, `terraform.tfvars` | Provider + connection (Authentik URL & API token)                                                                                                                               |
| `shared.tf`                                        | Shared data sources (flows, default OIDC scopes)                                                                                                                                |
| `freshrss.tf`, `portainer.tf`, `papra.tf`, `homepage.tf` | OIDC providers + applications (+ generated env file)                                                                                                                      |
| `proxy_forwardauth.tf`                             | Per service: proxy provider (`forward_single`), application, `<service>-access` group, policy binding                                                                            |
| `outpost.tf`                                       | Embedded outpost; all proxy providers attached automatically                                                                                                                    |

The embedded outpost is a pre-existing singleton adopted through an `import` block (requires **Terraform ≥ 1.6**), so no manual `terraform import` is needed on a fresh server.

**Usage**:

```bash
cd terraform/authentik
terraform init
terraform plan
terraform apply
```

> After `apply`, add your user to the relevant **`<service>-access`** groups, otherwise Forward Auth denies access.

### `terraform/arr/`

Codifies the Radarr / Sonarr / Prowlarr configuration (quality settings, indexers, download clients, notifications). It talks to each service over its internal URL (container name on `traefik_net`) authenticated by API key. Requires **Terraform ≥ 1.7** (conditional `import` blocks with `for_each`).

| File                     | Purpose                                                                                                                                                       |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `providers.tf`, `variables.tf`, `terraform.tfvars` | Providers + connection (URLs, API keys, qBittorrent, Telegram, paths)                                                               |
| `locals.tf`              | TRaSH-style **custom formats** (MULTi/TRUEFRENCH/FRENCH favoured; VOSTFR/VFQ/unwanted blocked) with per-resolution scores                                       |
| `radarr.tf`, `sonarr.tf` | Root folder, qBittorrent download client, custom formats, quality profiles, recycle bin                                                                       |
| `prowlarr.tf`            | qBittorrent download client, Radarr/Sonarr applications, Telegram notification                                                                                 |
| `indexers.tf`            | Prowlarr Cardigann indexers (Ygégé, Generation-Free, Nostradamus, Torr9, C411) — **adopted by import**                                                          |
| `sync_profile.tf`        | Prowlarr sync profiles with a per-indexer **minimum-seeders floor** (Ygégé/Leak = 2)                                                                           |
| `quality_definitions.tf` | TRaSH quality sizes (`min_size = 0` — custom formats do the filtering)                                                                                         |
| `imports.tf`             | Conditional imports — empty `*_import_id` ⇒ resource created; set ⇒ existing config adopted                                                                    |

**Usage**:

```bash
cd terraform/arr
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

> **Adopting an existing setup**: fill the `*_import_id` / `indexer_import_ids` values in `terraform.tfvars` so Terraform adopts the existing resources instead of creating duplicates. Leave them empty on a fresh server.

## 🔒 Security notes

- ✅ Private services reachable **only through the tailnet** (device identity = first auth layer)
- ✅ Centralised authentication, unified users/groups, native MFA, centralised auth logs
- ✅ CrowdSec + Traefik bouncer on the remaining public edge (jellyfin/seerr/auth/rss)
- ⚠️ **Single point of failure (assumed)**: if Authentik is down, every Forward Auth / OIDC **web UI** is inaccessible; the `/api` routes stay up
- ⚠️ Arr **web UIs** (`AuthenticationMethod=External`) have no protection of their own without Authentik — mitigated by the tailnet boundary
- ⚠️ The `/api` routes bypass Authentik and rely on the tailnet + the service's own key/token. Keep those keys secret and qBittorrent's WebUI auth enabled.

**Recommendations**:

1. Monitor Authentik (a healthcheck is configured)
2. Back up the PostgreSQL databases regularly
3. Alert on Authentik downtime
4. Periodically test a full-stack startup

### Disabling internal auth on Arr services

Only possible by editing `config.xml` directly:

```xml
<AuthenticationMethod>External</AuthenticationMethod>
```

**Procedure**:

1. `docker compose stop radarr sonarr prowlarr`
2. Edit the `config.xml` files in the Docker volumes
3. `docker compose start radarr sonarr prowlarr`
