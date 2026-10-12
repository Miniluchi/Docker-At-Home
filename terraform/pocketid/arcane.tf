# Arcane : OIDC natif ; accès réservé à arcane-access, mappé sur le rôle admin.

resource "pocketid_group" "arcane" {
  name          = "arcane-access"
  friendly_name = "Arcane"
}

resource "pocketid_client" "arcane" {
  name                = "Arcane"
  client_id           = "arcane"
  callback_urls       = ["https://arcane.lan.${var.domain_base}/auth/oidc/callback"]
  allowed_user_groups = [pocketid_group.arcane.id]
}

resource "local_sensitive_file" "arcane_env" {
  filename        = "${path.module}/generated/arcane.env"
  file_permission = "0600"
  content         = <<-EOT
    OIDC_ISSUER_URL=https://id.${var.domain_base}
    OIDC_CLIENT_ID=${pocketid_client.arcane.client_id}
    OIDC_CLIENT_SECRET=${pocketid_client.arcane.client_secret}
    OIDC_ROLE_MAPPINGS=[{"claimValue":"${pocketid_group.arcane.name}","roleId":"role_admin"}]
  EOT
}
