# Tailles (MB/min) : min = 0 -> on ne bloque JAMAIS sur la taille ; ce sont les
# profils + custom formats qui filtrent la qualité (LQ/YIFY/YTS bloquent les fake
# tiny releases). preferred/max gardés ≈ illimités. Les definitions préexistent
# (id requis) -> lues via data source puis mises à jour.

data "radarr_quality_definitions" "all" {}
data "sonarr_quality_definitions" "all" {}

locals {
  radarr_qdef = { for q in data.radarr_quality_definitions.all.quality_definitions : q.quality_name => q }
  sonarr_qdef = { for q in data.sonarr_quality_definitions.all.quality_definitions : q.quality_name => q }

  # Qualités gérées (HD/4K). min_size identique (0) -> simple set de noms.
  radarr_qualities = toset([
    "HDTV-1080p", "WEBDL-1080p", "WEBRip-1080p", "Bluray-1080p", "Remux-1080p",
    "HDTV-2160p", "WEBDL-2160p", "WEBRip-2160p", "Bluray-2160p", "Remux-2160p",
  ])
  # NB : les Remux Sonarr s'appellent « Bluray-1080p/2160p Remux » (≠ Radarr).
  sonarr_qualities = toset([
    "HDTV-1080p", "WEBDL-1080p", "WEBRip-1080p", "Bluray-1080p", "Bluray-1080p Remux",
    "HDTV-2160p", "WEBDL-2160p", "WEBRip-2160p", "Bluray-2160p", "Bluray-2160p Remux",
  ])
}

resource "radarr_quality_definition" "sizes" {
  for_each = local.radarr_qualities

  id             = local.radarr_qdef[each.key].id
  title          = local.radarr_qdef[each.key].title
  min_size       = 0
  preferred_size = 1999
  max_size       = 2000
}

resource "sonarr_quality_definition" "sizes" {
  for_each = local.sonarr_qualities

  id             = local.sonarr_qdef[each.key].id
  title          = local.sonarr_qdef[each.key].title
  min_size       = 0
  preferred_size = 995
  max_size       = 1000
}
