# WUD : OIDC natif. Préfixe de variables AUTHENTIK conservé (callback /auth/oidc/authentik/cb).
# Rôle admin via le claim groups (scope groups) ; accès réservé à wud-access.

resource "pocketid_group" "wud" {
  name          = "wud-access"
  friendly_name = "What's Up Docker"
}

resource "pocketid_client" "wud" {
  name                = "What's Up Docker"
  client_id           = "wud"
  callback_urls       = ["https://wud.lan.${var.domain_base}/auth/oidc/authentik/cb"]
  allowed_user_groups = [pocketid_group.wud.id]
}

resource "local_sensitive_file" "wud_env" {
  filename        = "${path.module}/generated/wud.env"
  file_permission = "0600"
  content         = <<-EOT
    WUD_AUTH_OIDC_AUTHENTIK_DISCOVERY=https://id.${var.domain_base}/.well-known/openid-configuration
    WUD_AUTH_OIDC_AUTHENTIK_CLIENTID=${pocketid_client.wud.client_id}
    WUD_AUTH_OIDC_AUTHENTIK_CLIENTSECRET=${pocketid_client.wud.client_secret}
    WUD_AUTH_OIDC_AUTHENTIK_ADMINGROUP=${pocketid_group.wud.name}
  EOT
}
