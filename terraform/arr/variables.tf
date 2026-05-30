# Connectivité API : URL internes (nom de conteneur sur traefik_net).
variable "radarr_url" {
  type        = string
  description = "URL interne de Radarr (nom de conteneur sur traefik_net)."
  default     = "http://radarr:7878"
}

variable "sonarr_url" {
  type        = string
  description = "URL interne de Sonarr (nom de conteneur sur traefik_net)."
  default     = "http://sonarr:8989"
}

variable "prowlarr_url" {
  type        = string
  description = "URL interne de Prowlarr (nom de conteneur sur traefik_net)."
  default     = "http://prowlarr:9696"
}

variable "radarr_api_key" {
  type        = string
  description = "Clé API Radarr (config.xml -> <ApiKey>)."
  sensitive   = true
}

variable "sonarr_api_key" {
  type        = string
  description = "Clé API Sonarr (config.xml -> <ApiKey>)."
  sensitive   = true
}

variable "prowlarr_api_key" {
  type        = string
  description = "Clé API Prowlarr (config.xml -> <ApiKey>)."
  sensitive   = true
}

# Chemins : casse EXACTE, partagée avec qBittorrent via ${MEDIA_PATH}:/data.
variable "radarr_root_folder_path" {
  type        = string
  description = "Root folder Radarr (films)."
  default     = "/data/Films"
}

variable "sonarr_root_folder_path" {
  type        = string
  description = "Root folder Sonarr (séries)."
  default     = "/data/Series"
}

# qBittorrent : tourne en network_mode service:gluetun -> vu des Arr = gluetun:8080.
variable "qbt_host" {
  type        = string
  description = "Host du WebUI qBittorrent vu depuis les Arr (conteneur gluetun)."
  default     = "gluetun"
}

variable "qbt_port" {
  type        = number
  description = "Port du WebUI qBittorrent."
  default     = 8080
}

variable "qbt_username" {
  type        = string
  description = "Identifiant qBittorrent (vide si auth désactivée)."
  default     = ""
}

variable "qbt_password" {
  type        = string
  description = "Mot de passe qBittorrent (vide si auth désactivée)."
  default     = ""
  sensitive   = true
}

variable "radarr_qbt_category" {
  type        = string
  description = "Catégorie qBittorrent côté Radarr (minuscule)."
  default     = "radarr"
}

variable "sonarr_qbt_category" {
  type        = string
  description = "Catégorie qBittorrent côté Sonarr (minuscule)."
  default     = "sonarr"
}

variable "telegram_bot_token" {
  type        = string
  description = "Token du bot Telegram."
  sensitive   = true
}

variable "telegram_chat_id" {
  type        = string
  description = "Chat ID Telegram destinataire."
  sensitive   = true
}

variable "radarr_profile_language" {
  type        = string
  description = "Langue des profils Radarr ('Any' pour laisser les custom formats décider)."
  default     = "French"
}

variable "ygege_url" {
  type        = string
  description = "Base URL de l'indexeur Cardigann Ygège (doit matcher une entrée 'links' de ygege.yml)."
  default     = "http://ygege:8715/"
}

variable "ygege_indexer_name" {
  type        = string
  description = "Nom affiché de l'indexeur Ygège dans Prowlarr."
  default     = "Ygégé"
}

variable "prowlarr_app_profile_id" {
  type        = number
  description = "ID du Sync/App Profile Prowlarr (1 = Standard par défaut)."
  default     = 1
}

variable "prowlarr_sync_level" {
  type        = string
  description = "Niveau de sync Prowlarr -> apps : 'disabled', 'addOnly' ou 'fullSync'."
  default     = "fullSync"
}

# IDs d'import (voir imports.tf). Vide => ressource créée ;
# renseigné => ressource existante adoptée. Serveur neuf : tout laisser vide.
variable "radarr_root_folder_import_id" {
  type        = string
  description = "ID du root folder Radarr existant à adopter."
  default     = ""
}

variable "radarr_download_client_import_id" {
  type        = string
  description = "ID du download client qBittorrent Radarr existant."
  default     = ""
}

variable "sonarr_root_folder_import_id" {
  type        = string
  description = "ID du root folder Sonarr existant à adopter."
  default     = ""
}

variable "sonarr_download_client_import_id" {
  type        = string
  description = "ID du download client qBittorrent Sonarr existant."
  default     = ""
}

variable "prowlarr_download_client_import_id" {
  type        = string
  description = "ID du download client qBittorrent Prowlarr existant."
  default     = ""
}

variable "prowlarr_application_radarr_import_id" {
  type        = string
  description = "ID de l'application Prowlarr->Radarr existante à adopter."
  default     = ""
}

variable "prowlarr_application_sonarr_import_id" {
  type        = string
  description = "ID de l'application Prowlarr->Sonarr existante à adopter."
  default     = ""
}

variable "prowlarr_notification_telegram_import_id" {
  type        = string
  description = "ID de la notification Telegram Prowlarr existante à adopter."
  default     = ""
}

variable "radarr_notification_telegram_import_id" {
  type        = string
  description = "ID de la notification Telegram Radarr existante à adopter."
  default     = ""
}

variable "sonarr_notification_telegram_import_id" {
  type        = string
  description = "ID de la notification Telegram Sonarr existante à adopter."
  default     = ""
}

variable "prowlarr_indexer_ygege_import_id" {
  type        = string
  description = "ID de l'indexeur Ygège existant à adopter (voir bug provider dans prowlarr.tf)."
  default     = ""
}
