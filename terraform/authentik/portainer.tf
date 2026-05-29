# --- Provider OAuth2/OIDC ---------------------------------------------------
resource "authentik_provider_oauth2" "portainer" {
  name               = "portainer"
  client_id          = "portainer"
  client_type        = "confidential"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc_default.ids

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://portainer.${var.domain_base}/"
    }
  ]
}

# --- Application ------------------------------------------------------
resource "authentik_application" "portainer" {
  name              = "Portainer"
  slug              = "portainer"
  protocol_provider = authentik_provider_oauth2.portainer.id
  open_in_new_tab   = true
}

# --- Fichier d'env consommé par docker-compose ------------------------
# Écrit les identifiants OIDC générés ainsi que les endpoints à
# renseigner dans la configuration OAuth de Portainer.
resource "local_sensitive_file" "portainer_env" {
  filename        = "${path.module}/generated/portainer.env"
  file_permission = "0600"
  content         = <<-EOT
    OAUTH_CLIENT_ID=${authentik_provider_oauth2.portainer.client_id}
    OAUTH_CLIENT_SECRET=${authentik_provider_oauth2.portainer.client_secret}
    OAUTH_AUTHORIZATION_URL=https://auth.${var.domain_base}/application/o/authorize/
    OAUTH_ACCESS_TOKEN_URL=https://auth.${var.domain_base}/application/o/token/
    OAUTH_RESOURCE_URL=https://auth.${var.domain_base}/application/o/userinfo/
    OAUTH_LOGOUT_URL=https://auth.${var.domain_base}/application/o/portainer/end-session/
    OAUTH_REDIRECT_URL=https://portainer.${var.domain_base}/
    OAUTH_USER_IDENTIFIER=preferred_username
    OAUTH_SCOPES=email openid profile
  EOT
}

# --- Outputs ----------------------------------------------------------
output "portainer_client_id" {
  value = authentik_provider_oauth2.portainer.client_id
}

output "portainer_client_secret" {
  value     = authentik_provider_oauth2.portainer.client_secret
  sensitive = true
}
