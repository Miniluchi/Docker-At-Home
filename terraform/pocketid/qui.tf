# qui : un seul utilisateur et aucune allowlist côté qui → accès restreint à qui-access.

resource "pocketid_group" "qui" {
  name          = "qui-access"
  friendly_name = "qui"
}

resource "pocketid_client" "qui" {
  name                = "qui"
  client_id           = "qui"
  callback_urls       = ["https://qui.lan.${var.domain_base}/api/auth/oidc/callback"]
  allowed_user_groups = [pocketid_group.qui.id]
}

resource "local_sensitive_file" "qui_env" {
  filename        = "${path.module}/generated/qui.env"
  file_permission = "0600"
  content         = <<-EOT
    QUI__OIDC_ISSUER=https://id.${var.domain_base}
    QUI__OIDC_CLIENT_ID=${pocketid_client.qui.client_id}
    QUI__OIDC_CLIENT_SECRET=${pocketid_client.qui.client_secret}
  EOT
}
