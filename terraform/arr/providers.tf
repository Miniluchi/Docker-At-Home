terraform {
  # >= 1.7 : blocs `import` avec `for_each` (imports conditionnels, voir imports.tf).
  required_version = ">= 1.7"

  required_providers {
    radarr = {
      source  = "devopsarr/radarr"
      version = "~> 2.3"
    }
    sonarr = {
      source  = "devopsarr/sonarr"
      version = "~> 3.4"
    }
    prowlarr = {
      source  = "devopsarr/prowlarr"
      version = "~> 3.2"
    }
  }
}

# URL internes (nom de conteneur sur traefik_net), jamais les URL publiques
# Traefik (interceptées par le Forward Auth Authentik).
provider "radarr" {
  url     = var.radarr_url
  api_key = var.radarr_api_key
}

provider "sonarr" {
  url     = var.sonarr_url
  api_key = var.sonarr_api_key
}

provider "prowlarr" {
  url     = var.prowlarr_url
  api_key = var.prowlarr_api_key
}
