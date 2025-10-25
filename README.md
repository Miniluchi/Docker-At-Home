# Docker At Home

Stack Docker pour auto-hébergement de services domestiques, organisée par catégorie.

## 📁 Structure

```
.
├── infrastructure/    # Traefik (reverse proxy)
├── database/         # PostgreSQL, MySQL, Redis
├── domotique/        # Home Assistant, Zigbee2MQTT
├── media/            # Plex, serveurs média
├── rss/              # Gestionnaire RSS
├── apps/             # N8N, Homarr, Planka, Secrith
└── storage/          # Solutions de stockage
```

## 🚀 Démarrage rapide

1. **Configuration**
   ```bash
   cp .env.example .env
   # Éditer .env avec vos valeurs
   ```

2. **Démarrer tous les services**
   ```bash
   docker compose up -d
   ```

3. **Démarrer une stack spécifique**
   ```bash
   docker compose -f infrastructure/docker-compose.yml up -d
   ```

## 🛠️ Gestion

```bash
# Arrêter tout
docker compose down

# Voir les logs
docker compose logs -f [service]

# Redémarrer un service
docker compose restart [service]
```

## ⚙️ Services principaux

- **Traefik** : Reverse proxy avec SSL automatique
- **Home Assistant** : Domotique
- **Plex** : Serveur média
- **N8N** : Automatisation
- **Homarr** : Dashboard
- **PostgreSQL/MySQL** : Bases de données
- **Redis** : Cache

## 📝 Notes

- Tous les services utilisent Traefik comme reverse proxy
- Les volumes persistent les données dans des répertoires locaux
- Configuration via variables d'environnement (`.env`)
