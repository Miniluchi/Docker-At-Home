# Docker At Home

Stack Docker pour auto-hébergement de services domestiques, organisée par profils fonctionnels.

## 📁 Architecture

Cette stack utilise un fichier `docker-compose.yml` unique avec des **profils** pour organiser les services par catégories :

- **infrastructure** : Services de base (Traefik, OMV-Proxy, Portainer, Watchtower, Homarr, Authentik)
- **dashboard** : Tableaux de bord (Homarr)
- **media** : Services liés aux médias (Jellyfin, Jellyseerr, Radarr, Sonarr, Prowlarr, qBittorrent)
- **domotique** : Services domotiques (Home Assistant)
- **automation** : Services d'automatisation (N8N avec PostgreSQL dédié)
- **tools** : Outils divers (Planka avec PostgreSQL dédié, Snapdrop)
- **all** : Tous les services

## 🚀 Démarrage rapide

1. **Configuration**

   ```bash
   cp .env.example .env
   # Éditer .env avec vos valeurs
   ```

2. **Démarrer tous les services**

   ```bash
   docker compose --profile all up -d
   ```

3. **Démarrer un profil spécifique**

   ```bash
   # Infrastructure (obligatoire en premier)
   docker compose --profile infrastructure up -d

   # Puis d'autres profils selon vos besoins
   docker compose --profile media up -d
   docker compose --profile domotique up -d
   ```

4. **Démarrer plusieurs profils simultanément**
   ```bash
   docker compose --profile infrastructure --profile media --profile domotique up -d
   ```

## 🛠️ Gestion

```bash
# Arrêter tous les services
docker compose --profile all down

# Arrêter un profil spécifique
docker compose --profile media down

# Voir les logs d'un service
docker compose logs -f [service]

# Voir les logs d'un profil
docker compose --profile media logs -f

# Redémarrer un service
docker compose restart [service]

# Redémarrer un profil
docker compose --profile media restart
```

## ⚙️ Services par profils

### 🏗️ Infrastructure

- **Traefik** : Reverse proxy avec SSL automatique (Let's Encrypt)
- **OMV-Proxy** : Proxy nginx pour OpenMediaVault
- **Portainer** : Gestion des conteneurs Docker
- **Watchtower** : Mises à jour automatiques des conteneurs avec notifications email
- **Homarr** : Dashboard principal d'accueil avec SSO Authentik
- **Authentik** : Serveur SSO/Identity Provider (OIDC, OAuth2) avec base de données PostgreSQL dédiée

### 🎬 Media

- **Jellyfin** : Serveur de streaming de médias (alternative open-source à Plex)
- **Jellyseerr** : Interface de demandes de médias pour Jellyfin
- **Radarr** : Gestionnaire automatique de films
- **Sonarr** : Gestionnaire automatique de séries TV
- **Prowlarr** : Gestionnaire d'indexeurs pour Radarr/Sonarr
- **qBittorrent** : Client torrent avec interface web

### 🏠 Domotique

- **Home Assistant** : Centre de contrôle domotique (mode host) avec intégration ZHA pour Zigbee

### 🤖 Automation

- **N8N** : Plateforme d'automatisation de workflows
- **N8N-DB** : Base de données PostgreSQL dédiée pour N8N

### 🛠️ Tools

- **Planka** : Tableau Kanban pour gestion de projets
- **Planka-DB** : Base de données PostgreSQL dédiée pour Planka
- **Snapdrop** : Partage de fichiers local P2P

## 📂 Structure des médias

La stack media utilise une structure unifiée dans `${MEDIA_PATH}` :

```
/srv/.../media/
├── downloads/          # Téléchargements qBittorrent
│   ├── movies/        # Films en cours
│   └── tv/            # Séries en cours
├── movies/            # Bibliothèque films (Jellyfin)
└── tv/                # Bibliothèque séries (Jellyfin)
```

**Configuration recommandée** :

- Radarr → Dossier racine : `/data/movies`
- Sonarr → Dossier racine : `/data/tv`
- qBittorrent → Téléchargements : `/data/downloads`
- Jellyfin → Bibliothèques : `/data/movies` et `/data/tv`

## 📋 Profils détaillés

### infrastructure

Services de base nécessaires au fonctionnement de la stack.

- **traefik** : Reverse proxy avec SSL automatique (Let's Encrypt)
- **omv-proxy** : Proxy nginx pour accès à OpenMediaVault via Traefik
- **portainer** : Interface web de gestion Docker
- **watchtower** : Mises à jour automatiques des conteneurs (vérification quotidienne)
- **homarr** : Dashboard principal avec widgets personnalisables et SSO OIDC Authentik
- **authentik-server** : Serveur SSO/Identity Provider avec support OIDC et OAuth2
- **authentik-worker** : Worker pour tâches en arrière-plan (provisioning, webhooks, etc.)
- **authentik-db** : PostgreSQL 16 dédié pour Authentik

### dashboard

Tableaux de bord et interfaces de contrôle.

- **homarr** : Dashboard avec widgets personnalisables

### media

Stack complète de gestion et diffusion de médias.

- **jellyfin** : Serveur de streaming avec support transcoding (GPU non requis)
- **jellyseerr** : Interface de demandes de médias avec gestion utilisateurs
- **radarr** : Automatisation téléchargement et organisation des films
- **sonarr** : Automatisation téléchargement et organisation des séries
- **prowlarr** : Gestion centralisée des indexeurs torrent/usenet
- **qbittorrent** : Client torrent avec interface web, configuration DNS personnalisée pour trackers

### domotique

Écosystème domotique avec support Zigbee natif.

- **homeassistant** : Centre de contrôle domotique (mode host pour accès périphériques)

### automation

Services d'automatisation et workflows avec base de données dédiée.

- **n8n** : Plateforme d'automatisation avec authentification HTTP Basic
- **n8n-db** : PostgreSQL 15 dédié pour persistance des workflows

### tools

Outils divers et utilitaires avec bases de données dédiées.

- **planka** : Tableau Kanban pour gestion de projets
- **planka-db** : PostgreSQL 15 dédié pour Planka
- **snapdrop** : Partage de fichiers local P2P (alternative à AirDrop)

## 🔐 Authentification SSO avec Authentik

### Présentation

**Authentik** est un Identity Provider (IdP) open-source qui fournit l'authentification unique (SSO) pour tous vos services. Il prend en charge plusieurs protocoles d'authentification :

- **OIDC** (OpenID Connect) : Utilisé par Homarr
- **OAuth2** : Pour les applications modernes
- **SAML** : Pour les applications d'entreprise
- **Proxy Provider** : Pour les applications sans support SSO natif (Radarr, Sonarr, Prowlarr)

### Services protégés par Authentik

#### 🔹 Authentification OIDC native

- **Homarr** : SSO OIDC avec support des groupes et auto-login optionnel
- **Jellyfin** : SSO OIDC configuré (à vérifier dans l'interface)

#### 🔹 Authentification via Proxy (Forward Auth)

Les services suivants utilisent Authentik comme proxy d'authentification via les middlewares Traefik :

- **Radarr** : Authentification externe désactivée (`AuthenticationMethod=External`)
- **Sonarr** : Authentification externe désactivée (`AuthenticationMethod=External`)
- **Prowlarr** : Authentification externe désactivée (`AuthenticationMethod=External`)

**⚠️ Important** : Ces services ont leur authentification interne désactivée et dépendent entièrement d'Authentik. Si Authentik ne démarre pas, ces services seront **inaccessibles** (erreur 502/503) mais **sécurisés**.

### Configuration des dépendances

Les services Arr (Radarr, Sonarr, Prowlarr) ont une dépendance explicite sur Authentik :

```yaml
depends_on:
  authentik-server:
    condition: service_healthy
```

**Comportement** :

- ✅ Les services Arr ne démarreront **que si Authentik est opérationnel**
- ✅ Garantit que l'authentification est disponible avant l'accès aux services
- ⚠️ Si Authentik tombe, les services Arr ne redémarreront pas automatiquement

### Accès à Authentik

- **URL** : `https://auth.${DOMAIN_BASE}`
- **Compte admin** : Configuré via `AUTHENTIK_BOOTSTRAP_EMAIL` et `AUTHENTIK_BOOTSTRAP_PASSWORD` dans `.env`

### Configuration des applications dans Authentik

Pour chaque service protégé par Authentik, vous devez créer :

1. **Provider** : Configure le protocole d'authentification (OIDC, Proxy, etc.)
2. **Application** : Relie le provider à votre service
3. **Outpost** : Pour les Proxy Providers (embedded outpost pour la stack Arr)

#### Exemple : Configuration Homarr (OIDC)

Variables d'environnement requises dans `.env` :

```bash
HOMARR_OIDC_CLIENT_ID=<client_id_depuis_authentik>
HOMARR_OIDC_CLIENT_SECRET=<client_secret_depuis_authentik>
HOMARR_OIDC_SLUG=<slug_application_authentik>
HOMARR_OIDC_AUTO_LOGIN=false  # true pour auto-login
```

#### Exemple : Configuration Stack Arr (Proxy Provider)

1. Créer un **Proxy Provider** dans Authentik
2. Créer une **Application** pour chaque service (Radarr, Sonarr, Prowlarr)
3. Déployer un **Embedded Outpost** nommé `arr-stack-embedded-outpost`
4. Les middlewares Traefik se connectent à : `http://ak-outpost-arr-stack-embedded-outpost:9000`

### Sécurité

**Avantages** :

- ✅ Authentification centralisée pour tous les services
- ✅ Gestion unifiée des utilisateurs et groupes
- ✅ Support 2FA/MFA natif
- ✅ Logs d'authentification centralisés

**Risques à considérer** :

- ⚠️ Point unique de défaillance (SPOF) : Si Authentik tombe, plusieurs services deviennent inaccessibles
- ⚠️ Services avec `AuthenticationMethod=External` n'ont **aucune protection** si Authentik ne fonctionne pas

**Recommandations** :

1. **Monitoring** : Surveiller l'état d'Authentik (healthcheck configuré)
2. **Sauvegardes** : Sauvegarder régulièrement la base de données PostgreSQL
3. **Alertes** : Configurer des notifications si Authentik devient indisponible
4. **Tests** : Tester régulièrement le démarrage de la stack complète

### Désactivation de l'authentification interne

Pour les services Arr, l'authentification interne a été désactivée en modifiant manuellement le fichier `config.xml` :

```xml
<AuthenticationMethod>External</AuthenticationMethod>
```

**Note** : Cette configuration n'est **pas disponible via variables d'environnement** et doit être modifiée directement dans les fichiers de configuration.

**Procédure** :

1. Arrêter les conteneurs : `docker compose stop radarr sonarr prowlarr`
2. Modifier les fichiers `config.xml` dans les volumes Docker
3. Redémarrer les conteneurs : `docker compose start radarr sonarr prowlarr`
