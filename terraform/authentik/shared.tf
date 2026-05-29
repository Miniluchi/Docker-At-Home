# ----------------------------------------------------------------------------
# Data sources communes à tous les services.
# ----------------------------------------------------------------------------

# Flow d'autorisation (implicit consent)
data "authentik_flow" "default_authorization" {
  slug = "default-provider-authorization-implicit-consent"
}

# Flow d'invalidation (logout) par défaut
data "authentik_flow" "default_invalidation" {
  slug = "default-provider-invalidation-flow"
}

# Scopes OIDC standards
data "authentik_property_mapping_provider_scope" "oidc_default" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-profile",
  ]
}
