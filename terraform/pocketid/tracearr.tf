# Tracearr : réutilise le groupe tracearr-access du forward auth.

resource "pocketid_client" "tracearr" {
  name                = "Tracearr"
  client_id           = "tracearr"
  callback_urls       = ["https://tracearr.lan.${var.domain_base}/api/v1/auth/oauth2/callback/oidc"]
  allowed_user_groups = [pocketid_group.forward_auth["tracearr"].id]
}

resource "local_sensitive_file" "tracearr_env" {
  filename        = "${path.module}/generated/tracearr.env"
  file_permission = "0600"
  content         = <<-EOT
    OIDC_ISSUER_URL=https://id.${var.domain_base}
    OIDC_CLIENT_ID=${pocketid_client.tracearr.client_id}
    OIDC_CLIENT_SECRET=${pocketid_client.tracearr.client_secret}
  EOT
}
