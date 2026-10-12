variable "pocketid_url" {
  type    = string
  default = "http://pocket-id:1411"
}

variable "pocketid_token" {
  type      = string
  sensitive = true
}

variable "domain_base" {
  type = string
}
