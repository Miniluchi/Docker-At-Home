# Indexeurs Prowlarr (Cardigann). Le provider ne sait pas CRÉER d'indexeur de
# façon fiable (bug "inconsistent values for sensitive attribute" sur `fields`) :
# on les CRÉE dans Prowlarr puis on les ADOPTE par import (indexer_import_ids),
# `fields` (clés incluses) restant géré côté Prowlarr -> ignore_changes.
# Ajouter un indexeur = le créer dans Prowlarr, 1 entrée ici + son id d'import.
locals {
  indexers = {
    ygege              = { name = "Ygégé", priority = 1, definition_file = "ygege", base_url = "http://ygege:8715/" }
    generation_free    = { name = "Generation-Free", priority = 2, definition_file = "generationfree-api", base_url = "https://generation-free.org/" }
    generation_free_fl = { name = "Generation-Free (Freeleech)", priority = 1, definition_file = "generationfree-api", base_url = "https://generation-free.org/" }
    nostradamus        = { name = "Nostradamus", priority = 2, definition_file = "nostradamus", base_url = "https://nostradamus.foo/" }
    torr9              = { name = "Torr9", priority = 2, definition_file = "torr9", base_url = "https://torr9.net/" }
    c411               = { name = "C411", priority = 2, definition_file = "c411", base_url = "https://c411.org/" }
  }
}

resource "prowlarr_indexer" "this" {
  for_each = local.indexers

  name            = each.value.name
  enable          = true
  implementation  = "Cardigann"
  config_contract = "CardigannSettings"
  protocol        = "torrent"
  app_profile_id  = 1
  priority        = each.value.priority

  fields = [
    { name = "definitionFile", text_value = each.value.definition_file },
    { name = "baseUrl", text_value = each.value.base_url },
  ]

  lifecycle {
    ignore_changes = [fields]
  }
}

moved {
  from = prowlarr_indexer.ygege
  to   = prowlarr_indexer.this["ygege"]
}

output "prowlarr_indexer_ids" {
  description = "ID Prowlarr par indexeur géré."
  value       = { for k, idx in prowlarr_indexer.this : k => idx.id }
}
