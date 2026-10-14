# Stirling PDF : OIDC natif (provider "pocketid" → callback /login/oauth2/code/pocketid) ;
# accès réservé à stirling-pdf-access.

resource "pocketid_group" "stirling_pdf" {
  name          = "stirling-pdf-access"
  friendly_name = "Stirling PDF"
}

resource "pocketid_client" "stirling_pdf" {
  name                = "Stirling PDF"
  client_id           = "stirling-pdf"
  callback_urls       = ["https://pdf.${var.domain_base}/login/oauth2/code/pocketid"]
  allowed_user_groups = [pocketid_group.stirling_pdf.id]
}

resource "local_sensitive_file" "stirling_pdf_env" {
  filename        = "${path.module}/generated/stirling-pdf.env"
  file_permission = "0600"
  content         = <<-EOT
    SECURITY_OAUTH2_ISSUER=https://id.${var.domain_base}
    SECURITY_OAUTH2_CLIENTID=${pocketid_client.stirling_pdf.client_id}
    SECURITY_OAUTH2_CLIENTSECRET=${pocketid_client.stirling_pdf.client_secret}
  EOT
}
