# Docker At Home

Stack Docker pour auto-hébergement de services domestiques, organisée par profils fonctionnels.

## 📁 Architecture

Cette stack utilise un fichier `docker-compose.yml` unique avec des **profils** pour organiser les services par catégories :

- **infrastructure** : Services de base (Traefik, Portainer, Watchtower)
- **dashboard** : Tableaux de bord (Homarr)
- **media** : Services liés aux médias (Plex, Overseerr)
- **domotique** : Services domotiques (Home Assistant, Zigbee2MQTT, Mosquitto)
- **database** : Bases de données (PostgreSQL, MySQL, Redis) et outils d'administration
- **rss** : Services RSS (FreshRSS, RSSHub)
- **automation** : Services d'automatisation (N8N)
- **storage** : Services de stockage (Samba)
- **tools** : Outils divers (Planka, Snapdrop)
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

- **Traefik** : Reverse proxy avec SSL automatique
- **Portainer** : Gestion des conteneurs
- **Watchtower** : Mises à jour automatiques
- **Homarr** : Dashboard principal

### 🎬 Media

- **Plex** : Serveur média
- **Overseerr** : Demandes de médias

### 🏠 Domotique

- **Home Assistant** : Centre de contrôle domotique
- **Zigbee2MQTT** : Bridge Zigbee vers MQTT
- **Mosquitto** : Broker MQTT

### 🗄️ Database

- **PostgreSQL** : Base de données principale
- **MySQL** : Base de données alternative
- **Redis** : Cache et sessions
- **phpMyAdmin** : Interface MySQL

### 📰 RSS

- **FreshRSS** : Lecteur RSS
- **RSSHub** : Générateur de flux RSS

### 🤖 Automation

- **N8N** : Automatisation de workflows

### 💾 Storage

- **Samba** : Partage de fichiers réseau

### 🛠️ Tools

- **Planka** : Gestion de projet Kanban
- **Snapdrop** : Partage de fichiers local

## 📋 Profils détaillés

### infrastructure

Services de base nécessaires au fonctionnement de la stack.

- **traefik** : Reverse proxy avec SSL automatique
- **portainer** : Interface de gestion Docker
- **watchtower** : Mises à jour automatiques des conteneurs
- **homarr** : Dashboard principal
- **omv-proxy** : Proxy pour OpenMediaVault

### dashboard

Tableaux de bord et interfaces de contrôle.

- **homarr** : Dashboard avec widgets personnalisables

### media

Services liés à la gestion et diffusion de médias.

- **plex** : Serveur de médias
- **overseerr** : Interface de demandes de médias

### domotique

Écosystème domotique complet.

- **homeassistant** : Centre de contrôle domotique
- **zigbee2mqtt** : Bridge pour appareils Zigbee
- **mosquitto** : Broker MQTT
- **homeassistant-proxy** : Proxy pour accès via Traefik

### database

Bases de données et outils d'administration.

- **postgres** : Base de données PostgreSQL
- **mysql** : Base de données MySQL
- **redis** : Cache Redis
- **phpmyadmin** : Interface d'administration MySQL

### rss

Services de gestion de flux RSS.

- **freshrss** : Lecteur RSS
- **rsshub** : Générateur de flux RSS

### automation

Services d'automatisation et workflows.

- **n8n** : Plateforme d'automatisation

### storage

Solutions de stockage et partage de fichiers.

- **samba** : Serveur de partage de fichiers SMB/CIFS

### tools

Outils divers et utilitaires.

- **planka** : Tableau Kanban
- **snapdrop** : Partage de fichiers local

## 📝 Notes

- Tous les services utilisent Traefik comme reverse proxy
- Les volumes persistent les données dans des répertoires locaux
- Configuration via variables d'environnement (`.env`)
- Le profil `infrastructure` doit être démarré en premier
- Les services Home Assistant utilisent le mode `host` pour l'accès aux périphériques
