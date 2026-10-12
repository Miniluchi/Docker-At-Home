terraform {
  required_providers {
    pocketid = {
      source  = "trozz/pocketid"
      version = "~> 2.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "pocketid" {
  base_url  = var.pocketid_url
  api_token = var.pocketid_token
}
