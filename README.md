# Docker At Home

Stack Docker pour auto-hébergement de services domestiques, organisée par profils fonctionnels.

## 📁 Architecture

Cette stack utilise un fichier `docker-compose.yml` unique avec des **profils** pour organiser les services par catégories :

- **infrastructure** : Services de base (Traefik, OMV-Proxy, Portainer, Watchtower, Homepage, Authentik, Glances)
- **dashboard** : Tableaux de bord (Homepage)
- **media** : Services liés aux médias (Jellyfin, Jellyseerr, Radarr, Sonarr, Prowlarr, qBittorrent)
- **domotique** : Services domotiques (Home Assistant)
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
- **Homepage** : Dashboard principal d'accueil avec SSO Authentik via Forward Auth
- **Authentik** : Serveur SSO/Identity Provider (OIDC, OAuth2, Forward Auth) avec base de données PostgreSQL dédiée
- **Glances** : Monitoring système en temps réel (accès local uniquement sur port 61208)

### 🎬 Media

- **Jellyfin** : Serveur de streaming de médias (alternative open-source à Plex)
- **Jellyseerr** : Interface de demandes de médias pour Jellyfin
- **Radarr** : Gestionnaire automatique de films
- **Sonarr** : Gestionnaire automatique de séries TV
- **Prowlarr** : Gestionnaire d'indexeurs pour Radarr/Sonarr
- **qBittorrent** : Client torrent avec interface web

### 🏠 Domotique

- **Home Assistant** : Centre de contrôle domotique (mode host) avec intégration ZHA pour Zigbee

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
- **portainer** : Interface web de gestion Docker (dépend d'Authentik pour le démarrage)
- **watchtower** : Mises à jour automatiques des conteneurs (vérification quotidienne)
- **homepage** : Dashboard principal avec widgets personnalisables et SSO Authentik via Forward Auth
- **authentik-server** : Serveur SSO/Identity Provider avec support OIDC, OAuth2 et Forward Auth
- **authentik-worker** : Worker pour tâches en arrière-plan (provisioning, webhooks, etc.)
- **authentik-db** : PostgreSQL 16 dédié pour Authentik
- **glances** : Monitoring système en temps réel (CPU, RAM, réseau, Docker) accessible sur port 61208

### dashboard

Tableaux de bord et interfaces de contrôle.

- **homepage** : Dashboard léger avec widgets personnalisables et protection SSO

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

### tools

Outils divers et utilitaires avec bases de données dédiées.

- **planka** : Tableau Kanban pour gestion de projets
- **planka-db** : PostgreSQL 15 dédié pour Planka
- **snapdrop** : Partage de fichiers local P2P (alternative à AirDrop)

## 🔐 Authentification SSO avec Authentik

### Présentation

**Authentik** est un Identity Provider (IdP) open-source qui fournit l'authentification unique (SSO) pour tous vos services. Il prend en charge plusieurs protocoles d'authentification :

- **OIDC** (OpenID Connect) : Pour les applications avec support natif
- **OAuth2** : Pour les applications modernes
- **SAML** : Pour les applications d'entreprise
- **Forward Auth** : Pour les applications sans support SSO natif (Radarr, Sonarr, Prowlarr, Homepage)

### Services protégés par Authentik

#### 🔹 Authentification Forward Auth (via Traefik)

Les services suivants utilisent Authentik comme proxy d'authentification via les middlewares Traefik Forward Auth :

- **Homepage** : Dashboard protégé par authentification Authentik
- **Radarr** : Authentification externe désactivée (`AuthenticationMethod=External`)
- **Sonarr** : Authentification externe désactivée (`AuthenticationMethod=External`)
- **Prowlarr** : Authentification externe désactivée (`AuthenticationMethod=External`)

**⚠️ Important** : Ces services ont leur authentification interne désactivée et dépendent entièrement d'Authentik. Si Authentik ne démarre pas, ces services seront **inaccessibles** (erreur 502/503) mais **sécurisés**.

#### 🔹 Authentification OIDC native (configuration manuelle)

- **Portainer** : SSO OIDC (configuration manuelle requise dans l'interface)
- **Jellyfin** : SSO OIDC (configuration via plugin SSO)
- **Planka** : SSO OIDC (configuration via variables d'environnement)

### Configuration des dépendances

Plusieurs services ont une dépendance explicite sur Authentik :

```yaml
depends_on:
  authentik-server:
    condition: service_healthy
```

**Services concernés** :

- Radarr, Sonarr, Prowlarr (Stack Arr)
- Portainer
- Homepage
- Planka

**Comportement** :

- ✅ Ces services ne démarreront **que si Authentik est opérationnel**
- ✅ Garantit que l'authentification est disponible avant l'accès aux services
- ⚠️ Si Authentik tombe, ces services ne redémarreront pas automatiquement

### Accès à Authentik

- **URL** : `https://auth.${DOMAIN_BASE}`
- **Compte admin** : Configuré via `AUTHENTIK_BOOTSTRAP_EMAIL` et `AUTHENTIK_BOOTSTRAP_PASSWORD` dans `.env`

### Configuration des applications dans Authentik

Pour chaque service protégé par Authentik, vous devez créer :

1. **Provider** : Configure le protocole d'authentification (OIDC, Forward Auth, etc.)
2. **Application** : Relie le provider à votre service
3. **Embedded Outpost** : Pour le Forward Auth (inclus dans le serveur Authentik)

#### Exemple : Configuration Homepage (Forward Auth)

Homepage utilise le Forward Auth intégré d'Authentik. La configuration est automatique via les labels Traefik :

```yaml
labels:
  - "traefik.http.routers.homepage.middlewares=authentik-homepage@docker"
  - "traefik.http.middlewares.authentik-homepage.forwardauth.address=http://authentik-server:9000/outpost.goauthentik.io/auth/traefik"
  - "traefik.http.middlewares.authentik-homepage.forwardauth.trustForwardHeader=true"
  - "traefik.http.middlewares.authentik-homepage.forwardauth.authResponseHeaders=X-authentik-username,X-authentik-groups,X-authentik-email,X-authentik-name,X-authentik-uid"
```

Variables d'environnement dans `.env` :

```bash
HOMEPAGE_ALLOWED_HOSTS=${DOMAIN_BASE}
HOMEPAGE_VAR_DOMAIN=${DOMAIN_BASE}
```

#### Exemple : Configuration Portainer (OIDC)

**⚠️ Note** : Portainer nécessite une configuration manuelle dans son interface web car il ne supporte pas les variables d'environnement pour OIDC.

**Étapes de configuration** :

1. **Dans Authentik** : Créer un provider OIDC
   - Aller dans `Applications` → `Providers` → `Create`
   - Type : `OAuth2/OpenID Provider`
   - Name : `portainer`
   - Authorization flow : Choisir un flow (ex: `default-authorization-flow`)
   - Redirect URIs : `https://portainer.${DOMAIN_BASE}`
   - Signing Key : Sélectionner une clé disponible
   - Copier le `Client ID` et `Client Secret` générés

2. **Dans Authentik** : Créer une application
   - Aller dans `Applications` → `Create`
   - Name : `Portainer`
   - Slug : `portainer`
   - Provider : Sélectionner le provider créé précédemment

3. **Dans Portainer** : Activer OIDC
   - Se connecter en tant qu'administrateur local
   - Aller dans `Settings` → `Authentication`
   - Activer `OAuth`
   - Renseigner :
     - **Automatic user provision** : On
     - **Provider** : Custom
     - **Client ID** : Celui généré dans Authentik
     - **Client Secret** : Celui généré dans Authentik
     - **Authorization URL** : `https://auth.${DOMAIN_BASE}/application/o/authorize/`
     - **Access token URL** : `https://auth.${DOMAIN_BASE}/application/o/token/`
     - **Resource URL** : `https://auth.${DOMAIN_BASE}/application/o/userinfo/`
     - **Redirect URL** : `https://portainer.${DOMAIN_BASE}`
     - **User identifier** : `preferred_username` ou `email`
     - **Scopes** : `openid profile email`

4. **Tester la connexion** : Se déconnecter et tester l'authentification via Authentik

**Variables d'environnement dans `.env`** (pour référence uniquement) :

```bash
PORTAINER_OIDC_CLIENT_ID=<client_id_depuis_authentik>
PORTAINER_OIDC_CLIENT_SECRET=<client_secret_depuis_authentik>
```

#### Exemple : Configuration Stack Arr (Forward Auth)

La stack Arr utilise le Forward Auth intégré d'Authentik via les middlewares Traefik. La configuration est similaire à Homepage :

1. Créer une **Application** dans Authentik pour chaque service (Radarr, Sonarr, Prowlarr)
2. Configurer un **Forward Auth Provider** pointant vers chaque application
3. Les middlewares Traefik se connectent directement à : `http://authentik-server:9000/outpost.goauthentik.io/auth/traefik`

### Monitoring avec Glances

**Glances** est un outil de monitoring système en temps réel accessible localement :

- **URL** : `http://<ip_serveur>:61208`
- **Fonctionnalités** :
  - Monitoring CPU, RAM, disques, réseau
  - Surveillance des conteneurs Docker
  - Accès en lecture seule au système hôte (PID host)

**⚠️ Sécurité** : Glances est accessible uniquement en local (pas d'exposition via Traefik) et n'est pas protégé par Authentik.

### Sécurité

**Avantages** :

- ✅ Authentification centralisée pour tous les services
- ✅ Gestion unifiée des utilisateurs et groupes
- ✅ Support 2FA/MFA natif
- ✅ Logs d'authentification centralisés
- ✅ Monitoring système avec Glances

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
