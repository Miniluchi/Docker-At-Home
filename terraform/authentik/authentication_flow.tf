# ----------------------------------------------------------------------------
# Flow d'authentification dédié.
#
# On ne modifie pas `default-authentication-flow` : son blueprint (state par
# défaut = present) réapplique name/title/designation/user_fields à chaque
# passage du worker et écraserait le titre. Ce flow-ci n'est pas géré par
# blueprint, donc rien ne le réécrit.
# ----------------------------------------------------------------------------

# Stages existants réutilisés tels quels (créés par les blueprints par défaut).
data "authentik_stage" "password" {
  name = "default-authentication-password"
}

data "authentik_stage" "mfa_validation" {
  name = "default-authentication-mfa-validation"
}

data "authentik_stage" "user_login" {
  name = "default-authentication-login"
}

# Identifiant + mot de passe dans un seul formulaire : `password_stage` ajoute
# le champ mot de passe au stage d'identification et le valide contre ce stage.
# Les gestionnaires de mots de passe remplissent donc les deux champs d'un coup.
resource "authentik_stage_identification" "combined" {
  name                      = "lan-authentication-identification"
  user_fields               = ["email", "username"]
  password_stage            = data.authentik_stage.password.id
  case_insensitive_matching = true
  pretend_user_exists       = true
}

resource "authentik_flow" "authentication" {
  name           = "authentik"
  title          = "Authentification"
  slug           = "lan-authentication"
  designation    = "authentication"
  authentication = "none"
  layout         = "stacked"
}

# 10 identification (login + mot de passe) -> 20 MFA -> 30 session
# Le stage mot de passe séparé n'est pas lié : il est déjà consommé par le
# formulaire combiné. Le stage MFA est en 2e écran (not_configured_action=skip
# côté stage : les comptes sans device passent au travers).
resource "authentik_flow_stage_binding" "identification" {
  target = authentik_flow.authentication.uuid
  stage  = authentik_stage_identification.combined.id
  order  = 10
}

resource "authentik_flow_stage_binding" "mfa_validation" {
  target = authentik_flow.authentication.uuid
  stage  = data.authentik_stage.mfa_validation.id
  order  = 20
}

resource "authentik_flow_stage_binding" "user_login" {
  target = authentik_flow.authentication.uuid
  stage  = data.authentik_stage.user_login.id
  order  = 30
}

# ----------------------------------------------------------------------------
# Brand : titre générique + suppression du pied de page « Powered by authentik ».
# Le brand par défaut est créé avec `state: created` par son blueprint : il
# n'est jamais réappliqué, les modifications sont donc permanentes.
# ----------------------------------------------------------------------------

data "authentik_brand" "default" {
  domain = "authentik-default"
}

data "authentik_flow" "invalidation" {
  slug = "default-invalidation-flow"
}

data "authentik_flow" "user_settings" {
  slug = "default-user-settings-flow"
}

import {
  to = authentik_brand.default
  id = data.authentik_brand.default.id
}

resource "authentik_brand" "default" {
  domain  = "authentik-default"
  default = true

  branding_title = "Authentification"

  # Repris tels quels : non déclarés, le provider les remettrait à null.
  # Le logo reste le lettrage authentik (aucun asset de remplacement fourni).
  branding_logo                    = "/static/dist/assets/icons/icon_left_brand.svg"
  branding_favicon                 = "/static/dist/assets/icons/icon.png"
  branding_default_flow_background = "/static/dist/assets/images/flow_background.jpg"

  flow_authentication = authentik_flow.authentication.uuid
  flow_invalidation   = data.authentik_flow.invalidation.id
  flow_user_settings  = data.authentik_flow.user_settings.id

  # « Powered by authentik » est ajouté en dur par le composant ak-brand-links.
  branding_custom_css = "ak-brand-links { display: none; }"
}
