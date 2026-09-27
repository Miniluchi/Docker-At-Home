# Indexeurs Prowlarr (Cardigann). Le provider ne sait pas CRÉER d'indexeur de
# façon fiable (bug "inconsistent values for sensitive attribute" sur `fields`) :
# on les CRÉE dans Prowlarr puis on les ADOPTE par import (indexer_import_ids),
# `fields` (clés incluses) restant géré côté Prowlarr -> ignore_changes.
# Ajouter un indexeur = le créer dans Prowlarr, 1 entrée ici + son id d'import.
locals {
  indexers = {
    generation_free = { name = "Generation-Free", priority = 1, definition_file = "generationfree-api", base_url = "https://generation-free.org/" }
    c411            = { name = "C411", priority = 3, definition_file = "c411", base_url = "https://c411.org/" }
    tr4ker          = { name = "TR4KER", priority = 3, definition_file = "tr4ker", base_url = "https://tr4ker.net/" }
  }
}

resource "prowlarr_indexer" "this" {
  for_each = local.indexers

  name            = each.value.name
  enable          = true
  implementation  = "Cardigann"
  config_contract = "CardigannSettings"
  protocol        = "torrent"
  app_profile_id  = prowlarr_sync_profile.standard.id
  priority        = each.value.priority

  fields = [
    { name = "definitionFile", text_value = each.value.definition_file },
    { name = "baseUrl", text_value = each.value.base_url },
  ]

  lifecycle {
    ignore_changes = [fields]
  }
}

output "prowlarr_indexer_ids" {
  description = "ID Prowlarr par indexeur géré."
  value       = { for k, idx in prowlarr_indexer.this : k => idx.id }
}
