# Prowlarr (indexeurs)

# Indexeur Ygège (définition Cardigann montée dans le conteneur :
# ./ygege.yml -> /config/Definitions/Custom/ygege.yml). baseUrl doit matcher une
# entrée 'links' de ygege.yml.
resource "prowlarr_indexer" "ygege" {
  name            = var.ygege_indexer_name
  enable          = true
  implementation  = "Cardigann"
  config_contract = "CardigannSettings"
  protocol        = "torrent"
  app_profile_id  = var.prowlarr_app_profile_id
  priority        = 1

  fields = [
    {
      name       = "definitionFile"
      text_value = "ygege"
    },
    {
      name       = "baseUrl"
      text_value = var.ygege_url
    },
  ]

  # Bug provider sur `fields` (sensible) -> create/replace échoue. On ignore les
  # changements de `fields` (adoption par import) ; modifier ygege_url ne sera
  # donc PAS répercuté : ajuster le baseUrl dans Prowlarr puis ré-importer.
  lifecycle {
    ignore_changes = [fields]
  }
}

resource "prowlarr_download_client_qbittorrent" "qbittorrent" {
  name     = "qBittorrent"
  enable   = true
  priority = 1
  host     = var.qbt_host
  port     = var.qbt_port
  use_ssl  = false
  username = var.qbt_username
  password = var.qbt_password
}

# Push des indexeurs vers Radarr/Sonarr. Catégories Newznab (movies 2xxx, TV 5xxx, anime 5070).
resource "prowlarr_application_radarr" "radarr" {
  name            = "Radarr"
  sync_level      = var.prowlarr_sync_level
  base_url        = var.radarr_url
  prowlarr_url    = var.prowlarr_url
  api_key         = var.radarr_api_key
  sync_categories = [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060, 2070, 2080]
}

resource "prowlarr_application_sonarr" "sonarr" {
  name                  = "Sonarr"
  sync_level            = var.prowlarr_sync_level
  base_url              = var.sonarr_url
  prowlarr_url          = var.prowlarr_url
  api_key               = var.sonarr_api_key
  sync_categories       = [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5090]
  anime_sync_categories = [5070]
}

resource "prowlarr_notification_telegram" "telegram" {
  name      = "Telegram"
  bot_token = var.telegram_bot_token
  chat_id   = var.telegram_chat_id

  on_grab                 = true
  on_health_issue         = true
  on_application_update   = true
  include_health_warnings = true
  include_manual_grabs    = true
}

output "prowlarr_indexer_ygege_id" {
  description = "ID de l'indexeur Ygège géré."
  value       = prowlarr_indexer.ygege.id
}

output "prowlarr_application_ids" {
  description = "IDs des applications Prowlarr (sync vers Radarr/Sonarr)."
  value = {
    radarr = prowlarr_application_radarr.radarr.id
    sonarr = prowlarr_application_sonarr.sonarr.id
  }
}
