# Docker At Home

Stack Docker pour auto-hébergement de services domestiques, organisée par profils fonctionnels.

## 📁 Architecture

Cette stack utilise un fichier `docker-compose.yml` unique avec des **profils** pour organiser les services par catégories :

- **infrastructure** : Services de base (Traefik, OMV-Proxy, Portainer, Watchtower, Homarr)
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
- **Homarr** : Dashboard principal d'accueil

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
- **homarr** : Dashboard principal avec widgets personnalisables

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
