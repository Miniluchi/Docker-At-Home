# --- Provider OAuth2/OIDC ---------------------------------------------------
resource "authentik_provider_oauth2" "freshrss" {
  name               = "freshrss"
  client_id          = "freshrss"
  client_type        = "confidential"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  property_mappings = data.authentik_property_mapping_provider_scope.oidc_default.ids

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://rss.${var.domain_base}/i/oidc/"
    }
  ]
}

# --- Application ------------------------------------------------------
resource "authentik_application" "freshrss" {
  name              = "FreshRSS"
  slug              = "freshrss"
  protocol_provider = authentik_provider_oauth2.freshrss.id
  open_in_new_tab   = true

}

# --- Fichier d'env consommé par docker-compose ------------------------
# Écrit les identifiants OIDC générés.
resource "local_sensitive_file" "freshrss_env" {
  filename        = "${path.module}/generated/freshrss.env"
  file_permission = "0600"
  content         = <<-EOT
    OIDC_CLIENT_ID=${authentik_provider_oauth2.freshrss.client_id}
    OIDC_CLIENT_SECRET=${authentik_provider_oauth2.freshrss.client_secret}
  EOT
}

# --- Outputs ----------------------------------------------------------
output "freshrss_client_id" {
  value = authentik_provider_oauth2.freshrss.client_id
}

output "freshrss_client_secret" {
  value     = authentik_provider_oauth2.freshrss.client_secret
  sensitive = true
}
