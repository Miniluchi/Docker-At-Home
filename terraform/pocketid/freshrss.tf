resource "pocketid_client" "freshrss" {
  name          = "FreshRSS"
  client_id     = "freshrss"
  callback_urls = ["https://rss.${var.domain_base}/i/oidc/"]
  # mod_auth_openidc n'envoie pas de PKCE par défaut
  pkce_enabled = false
}

resource "local_sensitive_file" "freshrss_env" {
  filename        = "${path.module}/generated/freshrss.env"
  file_permission = "0600"
  content         = <<-EOT
    OIDC_CLIENT_ID=${pocketid_client.freshrss.client_id}
    OIDC_CLIENT_SECRET=${pocketid_client.freshrss.client_secret}
  EOT
}
