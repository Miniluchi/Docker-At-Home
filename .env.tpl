# Configuration générale
TZ=Europe/Paris
PUID={{ pass://Docker-At-Home/General/PUID }}
PGID={{ pass://Docker-At-Home/General/PGID }}

# Traefik
TRAEFIK_ACME_EMAIL={{ pass://Docker-At-Home/Traefik/TRAEFIK_ACME_EMAIL }}

# Traefik DNS-01 (OVH) — certificats via challenge DNS (wildcard *.lan.${DOMAIN_BASE}
# pour les services privés tailnet + renouvellement du public sans exposer :80).
# Token généré sur https://eu.api.ovh.com/createToken/ (validité ILLIMITÉE, sinon les
# renouvellements casseront). Droits requis : GET/POST/DELETE sur /domain/zone/<domaine>/*
# OVH_ENDPOINT : région de l'API, "ovh-eu" pour un compte FR/EU.
OVH_ENDPOINT=ovh-eu
OVH_APPLICATION_KEY={{ pass://Docker-At-Home/OVH/OVH_APPLICATION_KEY }}
OVH_APPLICATION_SECRET={{ pass://Docker-At-Home/OVH/OVH_APPLICATION_SECRET }}
OVH_CONSUMER_KEY={{ pass://Docker-At-Home/OVH/OVH_CONSUMER_KEY }}

# Tailscale (sidecar dah-proxy) — accès privé tailnet-only aux services sensibles
# (cf. docs/acces-prive-tailscale.md). Auth key générée sur
# https://login.tailscale.com/admin/settings/keys (Reusable, NON-Ephemeral).
# Après 1re connexion : désactiver l'expiration de clé sur le nœud dans la console.
TS_AUTHKEY={{ pass://Docker-At-Home/Tailscale/TS_AUTHKEY }}

# Domaines
DOMAIN_BASE={{ pass://Docker-At-Home/General/DOMAIN_BASE }}

# Media - Chemin racine pour tous les médias (downloads, films, séries)
MEDIA_PATH={{ pass://Docker-At-Home/General/MEDIA_PATH }}

# Authentik - SSO/Identity Provider
AUTHENTIK_POSTGRES_USER={{ pass://Docker-At-Home/Authentik/AUTHENTIK_POSTGRES_USER }}
AUTHENTIK_POSTGRES_PASSWORD={{ pass://Docker-At-Home/Authentik/AUTHENTIK_POSTGRES_PASSWORD }}
AUTHENTIK_POSTGRES_DB={{ pass://Docker-At-Home/Authentik/AUTHENTIK_POSTGRES_DB }}
AUTHENTIK_SECRET_KEY={{ pass://Docker-At-Home/Authentik/AUTHENTIK_SECRET_KEY }}
# Admin de bootstrap créé au 1er démarrage (cf. README « Bootstrap admin »)
AUTHENTIK_BOOTSTRAP_PASSWORD="{{ pass://Docker-At-Home/Authentik/AUTHENTIK_BOOTSTRAP_PASSWORD }}"
AUTHENTIK_BOOTSTRAP_EMAIL={{ pass://Docker-At-Home/Authentik/AUTHENTIK_BOOTSTRAP_EMAIL }}

# Jellyfin
JELLYFIN_OIDC_CLIENT_ID={{ pass://Docker-At-Home/Jellyfin/JELLYFIN_OIDC_CLIENT_ID }}
JELLYFIN_OIDC_CLIENT_SECRET={{ pass://Docker-At-Home/Jellyfin/JELLYFIN_OIDC_CLIENT_SECRET }}

# Portainer
PORTAINER_OIDC_CLIENT_ID={{ pass://Docker-At-Home/Portainer/PORTAINER_OIDC_CLIENT_ID }}
PORTAINER_OIDC_CLIENT_SECRET={{ pass://Docker-At-Home/Portainer/PORTAINER_OIDC_CLIENT_SECRET }}

# SonarQube
SONARQUBE_POSTGRES_USER={{ pass://Docker-At-Home/SonarQube/SONARQUBE_POSTGRES_USER }}
SONARQUBE_POSTGRES_PASSWORD={{ pass://Docker-At-Home/SonarQube/SONARQUBE_POSTGRES_PASSWORD }}
SONARQUBE_POSTGRES_DB={{ pass://Docker-At-Home/SonarQube/SONARQUBE_POSTGRES_DB }}

# CrowdSec
CROWDSEC_BOUNCER_API_KEY={{ pass://Docker-At-Home/CrowdSec/CROWDSEC_BOUNCER_API_KEY }}
CROWDSEC_ENROLL_KEY={{ pass://Docker-At-Home/CrowdSec/CROWDSEC_ENROLL_KEY }}
# Machine LAPI dédiée au widget Homepage (cscli machines add homepage --password ... -f -)
CROWDSEC_HOMEPAGE_USERNAME=homepage
CROWDSEC_HOMEPAGE_PASSWORD={{ pass://Docker-At-Home/CrowdSec/CROWDSEC_HOMEPAGE_PASSWORD }}

# Homepage
RADARR_API_KEY={{ pass://Docker-At-Home/Homepage/RADARR_API_KEY }}
SONARR_API_KEY={{ pass://Docker-At-Home/Homepage/SONARR_API_KEY }}
# Secret de session de l'auth native Homepage (openssl rand -base64 32)
HOMEPAGE_AUTH_SECRET={{ pass://Docker-At-Home/Homepage/HOMEPAGE_AUTH_SECRET }}

# Jellystat
JELLYSTAT_POSTGRES_USER={{ pass://Docker-At-Home/Jellystat/JELLYSTAT_POSTGRES_USER }}
JELLYSTAT_POSTGRES_PASSWORD={{ pass://Docker-At-Home/Jellystat/JELLYSTAT_POSTGRES_PASSWORD }}
JELLYSTAT_POSTGRES_DB={{ pass://Docker-At-Home/Jellystat/JELLYSTAT_POSTGRES_DB }}
JELLYSTAT_JWT_SECRET={{ pass://Docker-At-Home/Jellystat/JELLYSTAT_JWT_SECRET }}

# Gluetun (ProtonVPN WireGuard) — clé WireGuard dédiée à gluetun (NAT-PMP coché), cf. gluetun#3196
PROTON_WIREGUARD_PRIVATE_KEY={{ pass://Docker-At-Home/Gluetun/PROTON_WIREGUARD_PRIVATE_KEY }}
# Rollback OpenVPN — identifiants OpenVPN/IKEv2 du compte Proton, username suffixé "+pmp"
PROTON_OPENVPN_USER={{ pass://Docker-At-Home/Gluetun/PROTON_OPENVPN_USER }}
PROTON_OPENVPN_PASSWORD={{ pass://Docker-At-Home/Gluetun/PROTON_OPENVPN_PASSWORD }}

# gluetun-qbt-watchdog (https://github.com/brunoorsolon/gluetun-qbt-watchdog)
# GLUETUN_API_KEY : clé du control server gluetun (docker run --rm qmcgaw/gluetun genkey)
GLUETUN_API_KEY={{ pass://Docker-At-Home/Gluetun-Watchdog/GLUETUN_API_KEY }}
QBT_USER={{ pass://Docker-At-Home/Gluetun-Watchdog/QBT_USER }}
QBT_PASS={{ pass://Docker-At-Home/Gluetun-Watchdog/QBT_PASS }}

# WUD - compte local read-only du widget Homepage (utilisateur "homepage")
WUD_HOMEPAGE_PASSWORD={{ pass://Docker-At-Home/WUD/WUD_HOMEPAGE_PASSWORD }}
