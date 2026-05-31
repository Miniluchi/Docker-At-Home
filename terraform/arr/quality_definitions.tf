# Tailles (MB/min) selon TRaSH : min spécifique par qualité, preferred/max quasi
# illimités (on ne bloque jamais sur la taille, profils + custom formats décident).
# Les definitions préexistent (id requis) -> lues via data source puis mises à jour.

data "radarr_quality_definitions" "all" {}
data "sonarr_quality_definitions" "all" {}

locals {
  radarr_qdef = { for q in data.radarr_quality_definitions.all.quality_definitions : q.quality_name => q }
  sonarr_qdef = { for q in data.sonarr_quality_definitions.all.quality_definitions : q.quality_name => q }

  # min par qualité (TRaSH). preferred/max constants par app (≈ illimité).
  radarr_quality_min = {
    "HDTV-1080p"   = 33.8
    "WEBDL-1080p"  = 12.5
    "WEBRip-1080p" = 12.5
    "Bluray-1080p" = 50.8
    "Remux-1080p"  = 102
    "HDTV-2160p"   = 85
    "WEBDL-2160p"  = 34.5
    "WEBRip-2160p" = 34.5
    "Bluray-2160p" = 102
    "Remux-2160p"  = 187.4
  }
  sonarr_quality_min = {
    "HDTV-1080p"         = 15
    "WEBDL-1080p"        = 15
    "WEBRip-1080p"       = 15
    "Bluray-1080p"       = 50.4
    "Bluray-1080p Remux" = 69.1
    "HDTV-2160p"         = 25
    "WEBDL-2160p"        = 25
    "WEBRip-2160p"       = 25
    "Bluray-2160p"       = 94.6
    "Bluray-2160p Remux" = 187.4
  }
}

resource "radarr_quality_definition" "sizes" {
  for_each = local.radarr_quality_min

  id             = local.radarr_qdef[each.key].id
  title          = local.radarr_qdef[each.key].title
  min_size       = each.value
  preferred_size = 1999
  max_size       = 2000
}

resource "sonarr_quality_definition" "sizes" {
  for_each = local.sonarr_quality_min

  id             = local.sonarr_qdef[each.key].id
  title          = local.sonarr_qdef[each.key].title
  min_size       = each.value
  preferred_size = 995
  max_size       = 1000
}
