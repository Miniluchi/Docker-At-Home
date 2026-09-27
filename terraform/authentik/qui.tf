# qui : WebUI qBittorrent, OIDC natif (QUI__OIDC_*).
# qui n'a qu'un utilisateur et aucune allowlist : toute identité acceptée par
# le provider peut se connecter → accès restreint au groupe qui-access.

# --- Provider OAuth2/OIDC ---------------------------------------------------
resource "authentik_provider_oauth2" "qui" {
  name               = "qui"
  client_id          = "qui"
  client_type        = "confidential"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc_default.ids

  # Liste explicite obligatoire (cf. homepage.tf) ; qui utilise authorization_code + PKCE S256.
  grant_types = ["authorization_code", "refresh_token"]

  # RS256 + JWKS publié (cf. homepage.tf) : sans clé, l'ID token serait signé en HS256.
  signing_key = data.authentik_certificate_key_pair.default.id

  allowed_redirect_uris = [
    {
      matching_mode     = "strict"
      redirect_uri_type = "authorization"
      url               = "https://qui.lan.${var.domain_base}/api/auth/oidc/callback"
    }
  ]
}

# --- Application ------------------------------------------------------
resource "authentik_application" "qui" {
  name              = "qui"
  slug              = "qui"
  protocol_provider = authentik_provider_oauth2.qui.id
  open_in_new_tab   = true
}

resource "authentik_group" "qui" {
  name = "qui-access"
}

resource "authentik_policy_binding" "qui" {
  target = authentik_application.qui.uuid
  group  = authentik_group.qui.id
  order  = 0
}

# --- Fichier d'env consommé par docker-compose ------------------------
# L'issuer doit correspondre exactement à celui de la discovery (slash final inclus).
resource "local_sensitive_file" "qui_env" {
  filename        = "${path.module}/generated/qui.env"
  file_permission = "0600"
  content         = <<-EOT
    QUI__OIDC_ISSUER=https://auth.${var.domain_base}/application/o/${authentik_application.qui.slug}/
    QUI__OIDC_CLIENT_ID=${authentik_provider_oauth2.qui.client_id}
    QUI__OIDC_CLIENT_SECRET=${authentik_provider_oauth2.qui.client_secret}
  EOT
}

# --- Outputs ----------------------------------------------------------
output "qui_client_id" {
  value = authentik_provider_oauth2.qui.client_id
}

output "qui_client_secret" {
  value     = authentik_provider_oauth2.qui.client_secret
  sensitive = true
}
