# Sonarr (séries)

resource "sonarr_root_folder" "series" {
  path = var.sonarr_root_folder_path
}

resource "sonarr_download_client_qbittorrent" "qbittorrent" {
  name        = "qBittorrent"
  enable      = true
  priority    = 1
  host        = var.qbt_host
  port        = var.qbt_port
  use_ssl     = false
  username    = var.qbt_username
  password    = var.qbt_password
  tv_category = var.sonarr_qbt_category
}

resource "sonarr_custom_format" "fr" {
  for_each = local.custom_formats

  name                                = each.value.name
  include_custom_format_when_renaming = true
  specifications                      = each.value.specifications
}

locals {
  # Un format_item à score 0 n'est pas persisté par Sonarr -> on l'exclut.
  sonarr_format_items_1080p = [
    for key, cf in sonarr_custom_format.fr : {
      name   = cf.name
      format = cf.id
      score  = try(local.custom_formats[key].score_1080p, local.custom_formats[key].score)
    } if try(local.custom_formats[key].score_1080p, local.custom_formats[key].score) != 0
  ]
  sonarr_format_items_2160p = [
    for key, cf in sonarr_custom_format.fr : {
      name   = cf.name
      format = cf.id
      score  = try(local.custom_formats[key].score_2160p, local.custom_formats[key].score)
    } if try(local.custom_formats[key].score_2160p, local.custom_formats[key].score) != 0
  ]
}

# NB : les Remux Sonarr s'appellent « Bluray-1080p/2160p Remux » (≠ Radarr).
data "sonarr_quality" "hdtv_1080p" { name = "HDTV-1080p" }
data "sonarr_quality" "webdl_1080p" { name = "WEBDL-1080p" }
data "sonarr_quality" "webrip_1080p" { name = "WEBRip-1080p" }
data "sonarr_quality" "bluray_1080p" { name = "Bluray-1080p" }
data "sonarr_quality" "remux_1080p" { name = "Bluray-1080p Remux" }

data "sonarr_quality" "hdtv_2160p" { name = "HDTV-2160p" }
data "sonarr_quality" "webdl_2160p" { name = "WEBDL-2160p" }
data "sonarr_quality" "webrip_2160p" { name = "WEBRip-2160p" }
data "sonarr_quality" "bluray_2160p" { name = "Bluray-2160p" }
data "sonarr_quality" "remux_2160p" { name = "Bluray-2160p Remux" }

# cutoff = Bluray : on upgrade jusqu'au Bluray puis stop (pas de Remux).
resource "sonarr_quality_profile" "series_1080p" {
  name             = "FR-1080p"
  upgrade_allowed  = true
  cutoff           = data.sonarr_quality.bluray_1080p.id
  min_format_score = 50

  quality_groups = [
    { qualities = [data.sonarr_quality.hdtv_1080p] },
    {
      id   = 1001
      name = "WEB 1080p"
      qualities = [
        data.sonarr_quality.webdl_1080p,
        data.sonarr_quality.webrip_1080p,
      ]
    },
    { qualities = [data.sonarr_quality.bluray_1080p] },
    { qualities = [data.sonarr_quality.remux_1080p] },
  ]

  format_items = local.sonarr_format_items_1080p
}

resource "sonarr_quality_profile" "series_2160p" {
  name             = "FR-2160p"
  upgrade_allowed  = true
  cutoff           = data.sonarr_quality.bluray_2160p.id
  min_format_score = 50

  quality_groups = [
    { qualities = [data.sonarr_quality.hdtv_2160p] },
    {
      id   = 2001
      name = "WEB 2160p"
      qualities = [
        data.sonarr_quality.webdl_2160p,
        data.sonarr_quality.webrip_2160p,
      ]
    },
    { qualities = [data.sonarr_quality.bluray_2160p] },
    { qualities = [data.sonarr_quality.remux_2160p] },
  ]

  format_items = local.sonarr_format_items_2160p
}

# Media management + naming : valeurs recommandées TRASH.
resource "sonarr_media_management" "config" {
  chmod_folder                = "755"
  chown_group                 = ""
  create_empty_folders        = false
  delete_empty_folders        = false
  download_propers_repacks    = "doNotPrefer"
  enable_media_info           = true
  episode_title_required      = "always"
  extra_file_extensions       = "srt,sub,ass"
  file_date                   = "none"
  hardlinks_copy              = true
  import_extra_files          = true
  minimum_free_space          = 100
  recycle_bin_days            = 7
  recycle_bin_path            = ""
  rescan_after_refresh        = "always"
  set_permissions             = false
  skip_free_space_check       = false
  unmonitor_previous_episodes = false
}

resource "sonarr_naming" "naming" {
  rename_episodes            = true
  replace_illegal_characters = true
  colon_replacement_format   = 4 # Smart Replace
  multi_episode_style        = 5 # Prefixed Range
  series_folder_format       = "{Series TitleYear}"
  season_folder_format       = "Season {season:00}"
  specials_folder_format     = "Specials"
  standard_episode_format    = "{Series TitleYear} - S{season:00}E{episode:00} - {Episode CleanTitle:90} {[Custom Formats]}{[Quality Full]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{[MediaInfo VideoDynamicRangeType]}{[Mediainfo VideoCodec]}{-Release Group}"
  daily_episode_format       = "{Series TitleYear} - {Air-Date} - {Episode CleanTitle:90} {[Custom Formats]}{[Quality Full]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{[MediaInfo VideoDynamicRangeType]}{[Mediainfo VideoCodec]}{-Release Group}"
  anime_episode_format       = "{Series TitleYear} - S{season:00}E{episode:00} - {absolute:000} - {Episode CleanTitle:90} {[Custom Formats]}{[Quality Full]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{[MediaInfo VideoDynamicRangeType]}{[Mediainfo VideoCodec]}{-Release Group}"
}

resource "sonarr_notification_telegram" "telegram" {
  name      = "Telegram"
  bot_token = var.telegram_bot_token
  chat_id   = var.telegram_chat_id

  on_grab                            = true
  on_download                        = true
  on_upgrade                         = true
  on_series_delete                   = true
  on_episode_file_delete             = false
  on_episode_file_delete_for_upgrade = false
  on_health_issue                    = true
  on_application_update              = true
  include_health_warnings            = true
}

output "sonarr_quality_profile_ids" {
  description = "IDs des profils de qualité Sonarr (à reporter dans Sonarr/Jellyseerr)."
  value = {
    "FR-1080p" = sonarr_quality_profile.series_1080p.id
    "FR-2160p" = sonarr_quality_profile.series_2160p.id
  }
}

output "sonarr_root_folder_id" {
  description = "ID du root folder Sonarr géré."
  value       = sonarr_root_folder.series.id
}
