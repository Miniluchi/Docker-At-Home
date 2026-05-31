# Radarr (films)

resource "radarr_root_folder" "films" {
  path = var.radarr_root_folder_path
}

resource "radarr_download_client_qbittorrent" "qbittorrent" {
  name           = "qBittorrent"
  enable         = true
  priority       = 1
  host           = var.qbt_host
  port           = var.qbt_port
  use_ssl        = false
  username       = var.qbt_username
  password       = var.qbt_password
  movie_category = var.radarr_qbt_category
}

resource "radarr_custom_format" "fr" {
  for_each = local.custom_formats

  name                                = each.value.name
  include_custom_format_when_renaming = true
  specifications                      = each.value.specifications
}

locals {
  # Un format_item à score 0 n'est pas persisté par Radarr -> on l'exclut
  # (sinon "inconsistent result": l'élément planifié n'a pas d'équivalent réel).
  radarr_format_items_1080p = [
    for key, cf in radarr_custom_format.fr : {
      name   = cf.name
      format = cf.id
      score  = try(local.custom_formats[key].score_1080p, local.custom_formats[key].score)
    } if try(local.custom_formats[key].score_1080p, local.custom_formats[key].score) != 0
  ]
  radarr_format_items_2160p = [
    for key, cf in radarr_custom_format.fr : {
      name   = cf.name
      format = cf.id
      score  = try(local.custom_formats[key].score_2160p, local.custom_formats[key].score)
    } if try(local.custom_formats[key].score_2160p, local.custom_formats[key].score) != 0
  ]
}

# Data sources : id/source/resolution réels lus dans l'app (pas de valeur en dur).
data "radarr_language" "profile" {
  name = var.radarr_profile_language
}

data "radarr_quality" "hdtv_1080p" { name = "HDTV-1080p" }
data "radarr_quality" "webdl_1080p" { name = "WEBDL-1080p" }
data "radarr_quality" "webrip_1080p" { name = "WEBRip-1080p" }
data "radarr_quality" "bluray_1080p" { name = "Bluray-1080p" }
data "radarr_quality" "remux_1080p" { name = "Remux-1080p" }

data "radarr_quality" "hdtv_2160p" { name = "HDTV-2160p" }
data "radarr_quality" "webdl_2160p" { name = "WEBDL-2160p" }
data "radarr_quality" "webrip_2160p" { name = "WEBRip-2160p" }
data "radarr_quality" "bluray_2160p" { name = "Bluray-2160p" }
data "radarr_quality" "remux_2160p" { name = "Remux-2160p" }

# cutoff = Bluray : on upgrade jusqu'au Bluray puis stop (pas de Remux).
resource "radarr_quality_profile" "movies_1080p" {
  name                = "FR-1080p"
  upgrade_allowed     = true
  cutoff              = data.radarr_quality.bluray_1080p.id
  min_format_score    = 50
  cutoff_format_score = 175
  language            = data.radarr_language.profile

  quality_groups = [
    { qualities = [data.radarr_quality.hdtv_1080p] },
    {
      id   = 1001
      name = "WEB 1080p"
      qualities = [
        data.radarr_quality.webdl_1080p,
        data.radarr_quality.webrip_1080p,
      ]
    },
    { qualities = [data.radarr_quality.bluray_1080p] },
    { qualities = [data.radarr_quality.remux_1080p] },
  ]

  format_items = local.radarr_format_items_1080p
}

resource "radarr_quality_profile" "movies_2160p" {
  name                = "FR-2160p"
  upgrade_allowed     = true
  cutoff              = data.radarr_quality.bluray_2160p.id
  min_format_score    = 50
  cutoff_format_score = 175
  language            = data.radarr_language.profile

  quality_groups = [
    { qualities = [data.radarr_quality.hdtv_2160p] },
    {
      id   = 2001
      name = "WEB 2160p"
      qualities = [
        data.radarr_quality.webdl_2160p,
        data.radarr_quality.webrip_2160p,
      ]
    },
    { qualities = [data.radarr_quality.bluray_2160p] },
    { qualities = [data.radarr_quality.remux_2160p] },
  ]

  format_items = local.radarr_format_items_2160p
}

# Media management + naming : valeurs recommandées TRASH.
resource "radarr_media_management" "config" {
  auto_rename_folders                         = false
  auto_unmonitor_previously_downloaded_movies = false
  chmod_folder                                = "755"
  chown_group                                 = ""
  copy_using_hardlinks                        = true
  create_empty_movie_folders                  = false
  delete_empty_folders                        = false
  download_propers_and_repacks                = "doNotPrefer"
  enable_media_info                           = true
  extra_file_extensions                       = "srt,sub,ass"
  file_date                                   = "none"
  import_extra_files                          = true
  minimum_free_space_when_importing           = 100
  paths_default_static                        = false
  recycle_bin                                 = var.recycle_bin_path
  recycle_bin_cleanup_days                    = 7
  rescan_after_refresh                        = "always"
  set_permissions_linux                       = false
  skip_free_space_check_when_importing        = false
}

resource "radarr_naming" "naming" {
  rename_movies              = true
  replace_illegal_characters = true
  colon_replacement_format   = "smart"
  movie_folder_format        = "{Movie CleanTitle} ({Release Year})"
  standard_movie_format      = "{Movie CleanTitle} {(Release Year)} [tmdb-{TmdbId}] - {edition-{Edition Tags}} {[MediaInfo 3D]}{[Custom Formats]}{[Quality Full]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{[MediaInfo VideoDynamicRangeType]}{[MediaInfo VideoCodec]}{-Release Group}"
}

resource "radarr_notification_telegram" "telegram" {
  name      = "Telegram"
  bot_token = var.telegram_bot_token
  chat_id   = var.telegram_chat_id

  on_grab                          = true
  on_download                      = true
  on_upgrade                       = true
  on_movie_added                   = false
  on_movie_delete                  = true
  on_movie_file_delete             = false
  on_movie_file_delete_for_upgrade = false
  on_health_issue                  = true
  on_application_update            = true
  include_health_warnings          = true
}

output "radarr_quality_profile_ids" {
  description = "IDs des profils de qualité Radarr (à reporter dans Radarr/Jellyseerr)."
  value = {
    "FR-1080p" = radarr_quality_profile.movies_1080p.id
    "FR-2160p" = radarr_quality_profile.movies_2160p.id
  }
}

output "radarr_root_folder_id" {
  description = "ID du root folder Radarr géré."
  value       = radarr_root_folder.films.id
}
