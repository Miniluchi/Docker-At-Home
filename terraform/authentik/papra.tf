# --- Provider OAuth2/OIDC ---------------------------------------------------
resource "authentik_provider_oauth2" "papra" {
  name               = "papra"
  client_id          = "papra"
  client_type        = "confidential"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc_default.ids

  # Callback better-auth (plugin genericOAuth) : /api/auth/oauth2/callback/<providerId>
  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://doc.lan.${var.domain_base}/api/auth/oauth2/callback/authentik"
    }
  ]
}

# --- Application ------------------------------------------------------
resource "authentik_application" "papra" {
  name              = "Papra"
  slug              = "papra"
  protocol_provider = authentik_provider_oauth2.papra.id
  open_in_new_tab   = true
}

# --- Fichier d'env consommé par docker-compose ------------------------
# Papra attend ses providers OIDC sous forme d'un JSON sur une seule ligne.
resource "local_sensitive_file" "papra_env" {
  filename        = "${path.module}/generated/papra.env"
  file_permission = "0600"
  content = <<-EOT
    AUTH_PROVIDERS_CUSTOMS=${jsonencode([{
  providerId      = "authentik"
  providerName    = "Authentik"
  providerIconUrl = "https://api.iconify.design/simple-icons:authentik.svg"
  type            = "oidc"
  clientId        = authentik_provider_oauth2.papra.client_id
  clientSecret    = authentik_provider_oauth2.papra.client_secret
  discoveryUrl    = "https://auth.${var.domain_base}/application/o/papra/.well-known/openid-configuration"
  scopes          = ["openid", "profile", "email"]
}])}
  EOT
}

# --- Outputs ----------------------------------------------------------
output "papra_client_id" {
  value = authentik_provider_oauth2.papra.client_id
}

output "papra_client_secret" {
  value     = authentik_provider_oauth2.papra.client_secret
  sensitive = true
}
