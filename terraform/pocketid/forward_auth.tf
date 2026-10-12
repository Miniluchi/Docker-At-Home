# Forward auth via Tinyauth : un groupe <service>-access par service, et un seul
# client OIDC "tinyauth". Les règles par app sont dans les TINYAUTH_APPS_* du compose.

locals {
  forward_auth_services = {
    radarr    = "Radarr"
    sonarr    = "Sonarr"
    prowlarr  = "Prowlarr"
    jellystat = "Jellystat"
    glances   = "Glances"
    openclaw  = "OpenClaw"
  }
}

resource "pocketid_group" "forward_auth" {
  for_each      = local.forward_auth_services
  name          = "${each.key}-access"
  friendly_name = each.value
}

resource "pocketid_client" "tinyauth" {
  name                = "Tinyauth"
  client_id           = "tinyauth"
  callback_urls       = ["https://tinyauth.lan.${var.domain_base}/api/oauth/callback/pocketid"]
  allowed_user_groups = [for g in pocketid_group.forward_auth : g.id]
}

resource "local_sensitive_file" "tinyauth_env" {
  filename        = "${path.module}/generated/tinyauth.env"
  file_permission = "0600"
  content         = <<-EOT
    TINYAUTH_OAUTH_PROVIDERS_POCKETID_CLIENTID=${pocketid_client.tinyauth.client_id}
    TINYAUTH_OAUTH_PROVIDERS_POCKETID_CLIENTSECRET=${pocketid_client.tinyauth.client_secret}
  EOT
}
