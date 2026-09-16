# Homepage : authentification OIDC native (v2.x) à la place du forward auth.
# Le provider next-auth embarqué s'appelle "homepage-oidc" : la redirect URI
# est donc /api/auth/callback/homepage-oidc.

# Sans signing_key, authentik signe l'ID token en symétrique (HS256, via le client
# secret) ; next-auth attend RS256 et rejette le callback. Le certificat auto-signé
# par défaut est une RSA 4096 : il fait passer le provider en RS256 et publie la
# clé publique sur le JWKS.
data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

# --- Provider OAuth2/OIDC ---------------------------------------------------
resource "authentik_provider_oauth2" "homepage" {
  name               = "homepage-oidc"
  client_id          = "homepage"
  client_type        = "confidential"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc_default.ids

  # Authentik 2026.8 impose une liste explicite : créé sans, le provider naît avec
  # grant_types=[] et refuse le code d'autorisation ("Invalid grant_type for provider").
  # Homepage (next-auth) n'utilise que le flow authorization_code + PKCE.
  grant_types = ["authorization_code", "refresh_token"]

  signing_key = data.authentik_certificate_key_pair.default.id

  allowed_redirect_uris = [
    {
      matching_mode     = "strict"
      redirect_uri_type = "authorization"
      url               = "https://lan.${var.domain_base}/api/auth/callback/homepage-oidc"
    }
  ]
}

# --- Application ------------------------------------------------------
# Reprise des ressources de proxy_forwardauth.tf : évite un destroy/create qui
# entrerait en conflit sur le slug "homepage" et perdrait les membres du groupe.
moved {
  from = authentik_application.forward_auth["homepage"]
  to   = authentik_application.homepage
}

resource "authentik_application" "homepage" {
  name              = "Homepage"
  slug              = "homepage"
  protocol_provider = authentik_provider_oauth2.homepage.id
}

# Accès réservé aux membres de homepage-access (parité avec l'ancien forward auth)
moved {
  from = authentik_group.forward_auth["homepage"]
  to   = authentik_group.homepage
}

resource "authentik_group" "homepage" {
  name = "homepage-access"
}

moved {
  from = authentik_policy_binding.forward_auth_group["homepage"]
  to   = authentik_policy_binding.homepage
}

resource "authentik_policy_binding" "homepage" {
  target = authentik_application.homepage.uuid
  group  = authentik_group.homepage.id
  order  = 0
}

# --- Fichier d'env consommé par docker-compose ------------------------
resource "local_sensitive_file" "homepage_env" {
  filename        = "${path.module}/generated/homepage.env"
  file_permission = "0600"
  content         = <<-EOT
    HOMEPAGE_OIDC_ISSUER=https://auth.${var.domain_base}/application/o/${authentik_application.homepage.slug}
    HOMEPAGE_OIDC_CLIENT_ID=${authentik_provider_oauth2.homepage.client_id}
    HOMEPAGE_OIDC_CLIENT_SECRET=${authentik_provider_oauth2.homepage.client_secret}
  EOT
}

# --- Outputs ----------------------------------------------------------
output "homepage_client_id" {
  value = authentik_provider_oauth2.homepage.client_id
}

output "homepage_client_secret" {
  value     = authentik_provider_oauth2.homepage.client_secret
  sensitive = true
}
