# WUD (What's Up Docker) : OIDC natif (WUD_AUTH_OIDC_AUTHENTIK_*).
# Rôle admin WUD accordé via le claim groups (scope profile) ; WUD refuse les
# utilisateurs hors groupe (DEFAULTROLE=none) et Authentik aussi (policy binding).

# --- Provider OAuth2/OIDC ---------------------------------------------------
resource "authentik_provider_oauth2" "wud" {
  name               = "wud"
  client_id          = "wud"
  client_type        = "confidential"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc_default.ids

  grant_types = ["authorization_code", "refresh_token"]

  # RS256 + JWKS publié (cf. homepage.tf).
  signing_key = data.authentik_certificate_key_pair.default.id

  allowed_redirect_uris = [
    {
      matching_mode     = "strict"
      redirect_uri_type = "authorization"
      url               = "https://wud.lan.${var.domain_base}/auth/oidc/authentik/cb"
    }
  ]
}

# --- Application ------------------------------------------------------
resource "authentik_application" "wud" {
  name              = "What's Up Docker"
  slug              = "wud"
  protocol_provider = authentik_provider_oauth2.wud.id
  open_in_new_tab   = true
}

resource "authentik_group" "wud" {
  name = "wud-access"
}

resource "authentik_policy_binding" "wud" {
  target = authentik_application.wud.uuid
  group  = authentik_group.wud.id
  order  = 0
}

# --- Fichier d'env consommé par docker-compose ------------------------
resource "local_sensitive_file" "wud_env" {
  filename        = "${path.module}/generated/wud.env"
  file_permission = "0600"
  content         = <<-EOT
    WUD_AUTH_OIDC_AUTHENTIK_DISCOVERY=https://auth.${var.domain_base}/application/o/${authentik_application.wud.slug}/.well-known/openid-configuration
    WUD_AUTH_OIDC_AUTHENTIK_CLIENTID=${authentik_provider_oauth2.wud.client_id}
    WUD_AUTH_OIDC_AUTHENTIK_CLIENTSECRET=${authentik_provider_oauth2.wud.client_secret}
    WUD_AUTH_OIDC_AUTHENTIK_ADMINGROUP=${authentik_group.wud.name}
  EOT
}

# --- Outputs ----------------------------------------------------------
output "wud_client_id" {
  value = authentik_provider_oauth2.wud.client_id
}

output "wud_client_secret" {
  value     = authentik_provider_oauth2.wud.client_secret
  sensitive = true
}
