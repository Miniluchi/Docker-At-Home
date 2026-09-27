# SonarQube Community Build : SSO via SAML (pas d'OIDC natif dans cette édition).
# ACS imposé par SonarQube : <server base URL>/oauth2/callback/saml.

data "authentik_property_mapping_provider_saml" "sonarqube" {
  managed_list = [
    "goauthentik.io/providers/saml/username",
    "goauthentik.io/providers/saml/name",
    "goauthentik.io/providers/saml/email",
  ]
}

# --- Provider SAML ----------------------------------------------------------
resource "authentik_provider_saml" "sonarqube" {
  name               = "sonarqube"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  acs_url            = "https://sonarqube.${var.domain_base}/oauth2/callback/saml"
  audience           = "sonarqube"
  sp_binding         = "post"
  signing_kp         = data.authentik_certificate_key_pair.default.id
  property_mappings  = data.authentik_property_mapping_provider_saml.sonarqube.ids
}

# --- Application ------------------------------------------------------
resource "authentik_application" "sonarqube" {
  name              = "SonarQube"
  slug              = "sonarqube"
  protocol_provider = authentik_provider_saml.sonarqube.id
  open_in_new_tab   = true
}

# --- Outputs ----------------------------------------------------------
# Valeurs à pousser dans SonarQube (api/settings/set).
output "sonarqube_saml_settings" {
  value = {
    "sonar.core.serverBaseURL"            = "https://sonarqube.${var.domain_base}"
    "sonar.auth.saml.applicationId"       = authentik_provider_saml.sonarqube.audience
    "sonar.auth.saml.providerName"        = "authentik"
    "sonar.auth.saml.providerId"          = "https://auth.${var.domain_base}/application/saml/${authentik_application.sonarqube.slug}/metadata/"
    "sonar.auth.saml.loginUrl"            = "https://auth.${var.domain_base}/application/saml/${authentik_application.sonarqube.slug}/"
    "sonar.auth.saml.certificate.secured" = data.authentik_certificate_key_pair.default.certificate_data
    "sonar.auth.saml.user.login"          = "http://schemas.goauthentik.io/2021/02/saml/username"
    "sonar.auth.saml.user.name"           = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    "sonar.auth.saml.user.email"          = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
  }
}
