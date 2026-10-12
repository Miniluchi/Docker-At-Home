# Portainer : valeurs à reporter dans l'UI (Settings → Authentication → OAuth).
# Portainer n'envoie pas de PKCE.

resource "pocketid_client" "portainer" {
  name          = "Portainer"
  client_id     = "portainer"
  callback_urls = ["https://portainer.lan.${var.domain_base}/"]
  pkce_enabled  = false
}

resource "local_sensitive_file" "portainer_env" {
  filename        = "${path.module}/generated/portainer.env"
  file_permission = "0600"
  content         = <<-EOT
    OAUTH_CLIENT_ID=${pocketid_client.portainer.client_id}
    OAUTH_CLIENT_SECRET=${pocketid_client.portainer.client_secret}
    OAUTH_AUTHORIZATION_URL=https://id.${var.domain_base}/authorize
    OAUTH_ACCESS_TOKEN_URL=https://id.${var.domain_base}/api/oidc/token
    OAUTH_RESOURCE_URL=https://id.${var.domain_base}/api/oidc/userinfo
    OAUTH_LOGOUT_URL=https://id.${var.domain_base}/api/oidc/end-session
    OAUTH_REDIRECT_URL=https://portainer.lan.${var.domain_base}/
    OAUTH_USER_IDENTIFIER=preferred_username
    OAUTH_SCOPES=openid email profile
  EOT
}
