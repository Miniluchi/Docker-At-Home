# Forward auth (proxy providers) servis par l'outpost embarqué.
# Par service : groupe <service>-access, proxy provider (forward_single),
# application, et binding réservant l'accès aux membres du groupe.

locals {
  # host = sous-domaine ("" = domaine racine)
  forward_auth_services = {
    omv         = { display = "OpenMediaVault", host = "omv" }
    radarr      = { display = "Radarr", host = "radarr" }
    sonarr      = { display = "Sonarr", host = "sonarr" }
    qbittorrent = { display = "qBittorrent", host = "qbt" }
    prowlarr    = { display = "Prowlarr", host = "prowlarr" }
    jellystat   = { display = "Jellystat", host = "jellystat" }
    glances     = { display = "Glances", host = "glances" }
    homepage    = { display = "Homepage", host = "" }
  }
}

resource "authentik_group" "forward_auth" {
  for_each = local.forward_auth_services
  name     = "${each.key}-access"
}

resource "authentik_provider_proxy" "forward_auth" {
  for_each           = local.forward_auth_services
  name               = each.key
  mode               = "forward_single"
  external_host      = each.value.host == "" ? "https://${var.domain_base}" : "https://${each.value.host}.${var.domain_base}"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc_default.ids
}

resource "authentik_application" "forward_auth" {
  for_each          = local.forward_auth_services
  name              = each.value.display
  slug              = each.key
  protocol_provider = authentik_provider_proxy.forward_auth[each.key].id
}

# Accès réservé aux membres de <service>-access
resource "authentik_policy_binding" "forward_auth_group" {
  for_each = local.forward_auth_services
  target   = authentik_application.forward_auth[each.key].uuid
  group    = authentik_group.forward_auth[each.key].id
  order    = 0
}
