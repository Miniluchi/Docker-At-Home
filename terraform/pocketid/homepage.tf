# Homepage (next-auth, provider "homepage-oidc") : accès réservé à homepage-access.

resource "pocketid_group" "homepage" {
  name          = "homepage-access"
  friendly_name = "Homepage"
}

resource "pocketid_client" "homepage" {
  name                = "Homepage"
  client_id           = "homepage"
  callback_urls       = ["https://lan.${var.domain_base}/api/auth/callback/homepage-oidc"]
  allowed_user_groups = [pocketid_group.homepage.id]
}

resource "local_sensitive_file" "homepage_env" {
  filename        = "${path.module}/generated/homepage.env"
  file_permission = "0600"
  content         = <<-EOT
    HOMEPAGE_OIDC_ISSUER=https://id.${var.domain_base}
    HOMEPAGE_OIDC_CLIENT_ID=${pocketid_client.homepage.client_id}
    HOMEPAGE_OIDC_CLIENT_SECRET=${pocketid_client.homepage.client_secret}
  EOT
}
