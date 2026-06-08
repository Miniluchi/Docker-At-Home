# Sync Profiles Prowlarr. minimum_seeders = plancher de seeders pour grabber,
# assigné par indexeur via app_profile_id (indexers.tf). Leak (Ygégé) à 2 : un
# relais u2p unique qui tombe après le grab laisse qBittorrent en metaDL à 0 o.

resource "prowlarr_sync_profile" "standard" {
  name                      = "Standard"
  minimum_seeders           = 1
  enable_rss                = true
  enable_automatic_search   = true
  enable_interactive_search = true
}

import {
  to = prowlarr_sync_profile.standard
  id = "1"
}

resource "prowlarr_sync_profile" "leak" {
  name                      = "Leak"
  minimum_seeders           = var.ygege_minimum_seeders
  enable_rss                = true
  enable_automatic_search   = true
  enable_interactive_search = true
}
