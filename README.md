# Docker At Home

Self-hosted Docker stack for home services, organised by functional profiles.

## 📁 Architecture

A single `docker-compose.yml` uses **profiles** to group services:

- **infrastructure** — Traefik, Tailscale, Arcane, WUD, Pocket ID, Tinyauth, Homepage, CrowdSec
- **dashboard** — Homepage
- **media** — Jellyfin, Seerr, Radarr, Sonarr, Prowlarr, qBittorrent + Gluetun, qui, Tracearr
- **devtools** — SonarQube, Pocket ID, Tinyauth
- **security** — CrowdSec
- **tools** — FreshRSS
- **all** — Every service

> The databases (Tracearr, SonarQube) start with their parent service.

### 🌐 Public vs private (Tailscale)

Only **Jellyfin**, **Seerr**, **Pocket ID** and **FreshRSS** are public (`*.${DOMAIN_BASE}`, CrowdSec in front). Everything else lives on `*.lan.${DOMAIN_BASE}`, reachable only through the tailnet: a Tailscale sidecar shares Traefik's network namespace, so the node's `100.x` IP exposes Traefik `:443` to authorized devices. TLS uses a Let's Encrypt DNS-01 wildcard (OVH provider), and SSO (Tinyauth Forward Auth, or native OIDC against Pocket ID where supported) stays on the private UIs as defense-in-depth. Full design, DNS plan and rollback: [`docs/acces-prive-tailscale.md`](docs/acces-prive-tailscale.md).

### 🛡️ Real client IPs (HAProxy)

OrbStack's port forwarding rewrites the source IP, which would blind CrowdSec (every visitor shows up as the `traefik_net` gateway). A native HAProxy on macOS therefore owns `:80`/`:443` and relays raw TCP to Traefik on `127.0.0.1:8080`/`8443` with PROXY protocol v2; Traefik only trusts that header from `192.168.97.1`. Config: [`haproxy/haproxy.cfg`](haproxy/haproxy.cfg).

```bash
brew install haproxy
ln -sf "$PWD/haproxy/haproxy.cfg" /opt/homebrew/etc/haproxy.cfg
brew services start haproxy   # launchd, starts at login like OrbStack
```

## 🚀 Quick start

1. **Configuration**

   Secrets live in Proton Pass (vault `Docker-At-Home`); `.env.tpl` references them and generates `.env`:

   ```bash
   pass-cli login
   pass-cli inject -i .env.tpl -o .env --force
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
- **Arcane** — Docker management UI (OIDC SSO via Pocket ID)
- **WUD** — Daily image update scan with automatic updates after a 1-day cool-down; infra (Traefik, Tailscale, CrowdSec, Pocket ID, Tinyauth, PostgreSQL, Gluetun) is excluded via the `wud.trigger.exclude=docker.update` label ([getwud/wud](https://github.com/getwud/wud))
- **Pocket ID** — OIDC identity provider (passkeys), single user/group directory (SQLite)
- **Tinyauth** — Traefik Forward Auth, login delegated to Pocket ID
- **Homepage** — Landing dashboard on `lan.${DOMAIN_BASE}`, native OIDC login against Pocket ID
- **CrowdSec** — Intrusion detection; feeds the Traefik bouncer middleware on the public routers

### 📊 dashboard

- **Homepage** — Dashboard with customisable widgets, protected by Pocket ID SSO

### 🎬 media

- **Jellyfin** — Media streaming server
- **Jellyseerr** — Media request interface for Jellyfin
- **Radarr** — Movie automation
- **Sonarr** — TV show automation
- **Prowlarr** — Indexer manager for Radarr/Sonarr
- **qBittorrent** — Torrent client, all traffic routed through Gluetun
- **qui** — Modern qBittorrent WebUI with native OIDC, plus a client proxy for external apps ([autobrr/qui](https://github.com/autobrr/qui))
- **Gluetun** — VPN client (WireGuard)
- **gluetun-qbt-watchdog** — Syncs Gluetun's forwarded port into qBittorrent and restarts it when the tunnel drops ([brunoorsolon/gluetun-qbt-watchdog](https://github.com/brunoorsolon/gluetun-qbt-watchdog))
- **Tracearr** — Jellyfin activity history and stats, OIDC via Pocket ID (TimescaleDB + Redis) ([connorgallopo/Tracearr](https://github.com/connorgallopo/Tracearr))
- **iSponsorBlockTV** — Skips/mutes YouTube ads and SponsorBlock segments on the Apple TV via the Lounge API ([dmunozv04/iSponsorBlockTV](https://github.com/dmunozv04/iSponsorBlockTV))

### 🧰 devtools

- **SonarQube** — Code quality / static analysis (dedicated PostgreSQL)
- **Pocket ID**, **Tinyauth** — see _infrastructure_

### 🛡️ security

- **CrowdSec** — Behaviour-based intrusion detection; blocks flagged IPs on the public routers (jellyfin/seerr/id/rss)

### 🧪 tools

- **FreshRSS** — RSS aggregator (OIDC SSO via Pocket ID)

### 🤖 ai

- **OpenClaw** — Personal AI assistant reached over WhatsApp (dedicated number, sender allowlist), headless Chromium. Claude subscription (Sonnet, adaptive thinking; Haiku for utility and heartbeats), native LM Studio as fallback (`host.docker.internal:1234`). Control UI on `openclaw.lan.${DOMAIN_BASE}` (Tinyauth + gateway token). Isolated on `openclaw_net` (shared with Traefik only), no `docker.sock`, no host binds ([openclaw/openclaw](https://github.com/openclaw/openclaw))

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

## 🔐 SSO with Pocket ID + Tinyauth

- **Pocket ID** (`https://id.${DOMAIN_BASE}`) — OIDC provider, passkey login, single source of users and groups. Admin created at `/setup` on first start.
- **Tinyauth** (`tinyauth.lan.${DOMAIN_BASE}`) — Forward Auth for apps without native SSO; it has no local users and redirects straight to Pocket ID.

### Forward Auth (Traefik → Tinyauth)

Gated on their private hostnames (`*.lan.${DOMAIN_BASE}`), each behind a dedicated **`<service>-access` group**:

`radarr`, `sonarr`, `prowlarr`, `tracearr`, `glances`, `openclaw`

Routers use the `tinyauth@docker` middleware (`http://tinyauth:3000/api/auth/traefik`). Per-app rules are `TINYAUTH_APPS_<APP>_CONFIG_DOMAIN` / `_OAUTH_GROUPS` variables on the `tinyauth` service (no Docker socket). An app without a rule is open to any account allowed by the `tinyauth` client.

> **Arr services**: Radarr, Sonarr and Prowlarr have their internal auth disabled (`<AuthenticationMethod>External</AuthenticationMethod>`) and rely entirely on Tinyauth for their **web UI**. If Tinyauth or Pocket ID is down the UI is unreachable but secured.

### API routes outside Forward Auth

API clients send an API key, not a session, so Forward Auth would block them. A higher-priority router exposes each service's API path bypassing Tinyauth, on the private hostname:

| Service     | Router            | Rule                                          | Auth on the API                     |
| ----------- | ----------------- | --------------------------------------------- | ----------------------------------- |
| Radarr      | `radarr-api`      | `Host(radarr.lan.…) && PathPrefix(/api)`      | `X-Api-Key`                         |
| Sonarr      | `sonarr-api`      | `Host(sonarr.lan.…) && PathPrefix(/api)`      | `X-Api-Key`                         |
| Prowlarr    | `prowlarr-api`    | `Host(prowlarr.lan.…) && PathPrefix(/api)`    | `X-Api-Key`                         |

> `priority=100` makes the `/api` prefix win over the catch-all UI router. These routes stay reachable when Tinyauth is down.

> **qBittorrent** has no Traefik route: its UI is served by **qui** (`qui.lan.…`), and native clients (Helmarr) go through qui's client proxy (`/proxy/<key>`). qBittorrent stays reachable internally at `gluetun:8080`, so keep its WebUI auth **enabled**.

### Native OIDC

Issuer `https://id.${DOMAIN_BASE}` (discovery `/.well-known/openid-configuration`); add the `groups` scope where group claims are needed.

- **FreshRSS** — OIDC (fully managed by Terraform, credentials injected via env file)
- **qui** — OIDC (fully managed by Terraform; built-in login disabled, access gated on the `qui-access` group)
- **Arcane** — OIDC (fully managed by Terraform; admin role and access gated on the `arcane-access` group)
- **WUD** — OIDC (fully managed by Terraform; admin role and access gated on the `wud-access` group; variables keep the `WUD_AUTH_OIDC_AUTHENTIK_*` prefix to keep the callback URL)
- **Homepage** — OIDC (fully managed by Terraform; access gated on the `homepage-access` group)
- **Seerr** — OIDC (client created manually in Pocket ID)
- **Jellyfin** — OIDC via the SSO plugin (manual)
- **SonarQube** — local login (no SAML in Pocket ID)

> Pocket ID asks each user to consent once per client.

## 🧬 Infrastructure as Code (Terraform)

Two independent modules under `terraform/`:

- `terraform/pocketid/` — Pocket ID clients and groups (provider `trozz/pocketid`)
- `terraform/arr/` — Radarr / Sonarr / Prowlarr (providers `devopsarr/{radarr,sonarr,prowlarr}`)

### `terraform/pocketid/`

| File                                               | Purpose                                                                  |
| -------------------------------------------------- | ------------------------------------------------------------------------ |
| `providers.tf`, `variables.tf`, `terraform.tfvars` | Provider + connection (Pocket ID URL & API key, `domain_base`)           |
| `freshrss.tf`, `homepage.tf`, `qui.tf`, `wud.tf`, `arcane.tf` | OIDC clients (+ `<app>-access` group, generated env file) |
| `forward_auth.tf`                                  | `<service>-access` groups + the single `tinyauth` client (`generated/tinyauth.env`) |

`client_secret` is only readable at creation and lives in the state: keep `terraform.tfstate` out of git (it is).

**Usage** (from a container on `traefik_net`, the public URL is not reachable from the host):

```bash
cd terraform/pocketid
docker run --rm -it --network traefik_net -v "$PWD":/work -w /work \
  --entrypoint sh hashicorp/terraform:latest -c "terraform init && terraform apply"
```

> After `apply`, add users to the relevant **`<service>-access`** groups in Pocket ID, otherwise access is denied.

> Fresh `pocketid_data` volume: the distroless image runs as uid 65532, so `chown 65532:65532` the volume once before the first start.

### `terraform/arr/`

Codifies the Radarr / Sonarr / Prowlarr configuration (quality settings, indexers, download clients, notifications). It talks to each service over its internal URL (container name on `traefik_net`) authenticated by API key. Requires **Terraform ≥ 1.7** (conditional `import` blocks with `for_each`).

| File                     | Purpose                                                                                                                                                       |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `providers.tf`, `variables.tf`, `terraform.tfvars` | Providers + connection (URLs, API keys, qBittorrent, Telegram, paths)                                                               |
| `locals.tf`              | TRaSH-style **custom formats** (MULTi/TRUEFRENCH/FRENCH favoured; VOSTFR/VFQ/unwanted blocked) with per-resolution scores                                       |
| `radarr.tf`, `sonarr.tf` | Root folder, qBittorrent download client, custom formats, quality profiles, recycle bin                                                                       |
| `prowlarr.tf`            | qBittorrent download client, Radarr/Sonarr applications, Telegram notification                                                                                 |
| `indexers.tf`            | Prowlarr Cardigann indexers (Generation-Free, C411, TR4KER, Nostradamus — disabled) — **adopted by import**, `enable` per indexer                  |
| `sync_profile.tf`        | Prowlarr sync profile (**minimum-seeders floor** for grabbing)                                                                                                 |
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
- ✅ Centralised authentication, unified users/groups, passkeys, centralised auth logs
- ✅ CrowdSec + Traefik bouncer on the remaining public edge (jellyfin/seerr/id/rss)
- ⚠️ **Single point of failure (assumed)**: if Pocket ID is down, every Forward Auth / OIDC **web UI** is inaccessible (Tinyauth too for Forward Auth); the `/api` routes stay up
- ⚠️ Arr **web UIs** (`AuthenticationMethod=External`) have no protection of their own without Tinyauth — mitigated by the tailnet boundary
- ⚠️ The `/api` routes (and qui's `/proxy/<key>`) bypass Tinyauth and rely on the tailnet + the service's own key/token. Keep those keys secret and qBittorrent's WebUI auth enabled.
- ⚠️ **OpenClaw** can still reach the Mac's own services (OrbStack forwards `host.docker.internal`, even to localhost-only listeners), the LAN, and every Traefik route including `*.lan` (via `traefik` or `host.docker.internal:8443`): the tailnet is not a boundary for it, Tinyauth/Pocket ID and the services' own keys are. Web pages it reads can carry prompt injection, so it gets no `docker.sock`, no host binds and no access to the other containers.

**Recommendations**:

1. Monitor Pocket ID and Tinyauth (healthchecks are configured)
2. Back up the PostgreSQL databases regularly
3. Alert on Pocket ID downtime
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
