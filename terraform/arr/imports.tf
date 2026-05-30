# Imports conditionnels (Terraform >= 1.7). Le même code couvre les deux cas :
#   - *_import_id vide      -> for_each vide -> ressource CRÉÉE (serveur neuf).
#   - *_import_id renseigné -> ressource ADOPTÉE (Arr déjà configuré).

locals {
  import_ids = {
    radarr_root_folder       = var.radarr_root_folder_import_id
    radarr_download_client   = var.radarr_download_client_import_id
    sonarr_root_folder       = var.sonarr_root_folder_import_id
    sonarr_download_client   = var.sonarr_download_client_import_id
    prowlarr_download_client = var.prowlarr_download_client_import_id
    prowlarr_app_radarr      = var.prowlarr_application_radarr_import_id
    prowlarr_app_sonarr      = var.prowlarr_application_sonarr_import_id
    prowlarr_notif_telegram  = var.prowlarr_notification_telegram_import_id
    radarr_notif_telegram    = var.radarr_notification_telegram_import_id
    sonarr_notif_telegram    = var.sonarr_notification_telegram_import_id
    prowlarr_indexer_ygege   = var.prowlarr_indexer_ygege_import_id
  }
}

import {
  for_each = local.import_ids.radarr_root_folder != "" ? toset([local.import_ids.radarr_root_folder]) : toset([])
  to       = radarr_root_folder.films
  id       = each.value
}

import {
  for_each = local.import_ids.radarr_download_client != "" ? toset([local.import_ids.radarr_download_client]) : toset([])
  to       = radarr_download_client_qbittorrent.qbittorrent
  id       = each.value
}

import {
  for_each = local.import_ids.sonarr_root_folder != "" ? toset([local.import_ids.sonarr_root_folder]) : toset([])
  to       = sonarr_root_folder.series
  id       = each.value
}

import {
  for_each = local.import_ids.sonarr_download_client != "" ? toset([local.import_ids.sonarr_download_client]) : toset([])
  to       = sonarr_download_client_qbittorrent.qbittorrent
  id       = each.value
}

import {
  for_each = local.import_ids.prowlarr_download_client != "" ? toset([local.import_ids.prowlarr_download_client]) : toset([])
  to       = prowlarr_download_client_qbittorrent.qbittorrent
  id       = each.value
}

import {
  for_each = local.import_ids.prowlarr_app_radarr != "" ? toset([local.import_ids.prowlarr_app_radarr]) : toset([])
  to       = prowlarr_application_radarr.radarr
  id       = each.value
}

import {
  for_each = local.import_ids.prowlarr_app_sonarr != "" ? toset([local.import_ids.prowlarr_app_sonarr]) : toset([])
  to       = prowlarr_application_sonarr.sonarr
  id       = each.value
}

import {
  for_each = local.import_ids.prowlarr_notif_telegram != "" ? toset([local.import_ids.prowlarr_notif_telegram]) : toset([])
  to       = prowlarr_notification_telegram.telegram
  id       = each.value
}

import {
  for_each = local.import_ids.radarr_notif_telegram != "" ? toset([local.import_ids.radarr_notif_telegram]) : toset([])
  to       = radarr_notification_telegram.telegram
  id       = each.value
}

import {
  for_each = local.import_ids.sonarr_notif_telegram != "" ? toset([local.import_ids.sonarr_notif_telegram]) : toset([])
  to       = sonarr_notification_telegram.telegram
  id       = each.value
}

import {
  for_each = local.import_ids.prowlarr_indexer_ygege != "" ? toset([local.import_ids.prowlarr_indexer_ygege]) : toset([])
  to       = prowlarr_indexer.ygege
  id       = each.value
}
