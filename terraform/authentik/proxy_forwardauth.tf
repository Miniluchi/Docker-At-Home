# Forward auth (proxy providers) servis par l'outpost embarqué.
# Par service : groupe <service>-access, proxy provider (forward_single),
# application, et binding réservant l'accès aux membres du groupe.

# Scopes pour les proxy providers forward-auth. En plus des scopes OIDC standards,
# un proxy provider REQUIERT le mapping "scope-proxy" (que l'outpost embarqué utilise) ;
# "scope-entitlements" fait aussi partie des mappings ajoutés par défaut par Authentik.
# Les omettre ferait retirer scope-proxy des providers → forward auth cassé sur toute la stack.
# (data source distincte de oidc_default, qui reste réservée aux vrais OIDC : freshrss/portainer.)
data "authentik_property_mapping_provider_scope" "forward_auth" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/proxy/scope-proxy",
    "goauthentik.io/providers/oauth2/scope-entitlements",
  ]
}

locals {
  # host = sous-domaine dans la zone privée lan.<domain_base> ("" = apex de la zone).
  # Ces services ne sont joignables que via le tailnet (cf. docs/acces-prive-tailscale.md) ;
  # le forward auth est conservé en défense-en-profondeur par-dessus Tailscale.
  forward_auth_services = {
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
  external_host      = each.value.host == "" ? "https://lan.${var.domain_base}" : "https://${each.value.host}.lan.${var.domain_base}"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  property_mappings  = data.authentik_property_mapping_provider_scope.forward_auth.ids
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
