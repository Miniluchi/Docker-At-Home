# Outpost embarqué
data "authentik_outpost" "embedded" {
  name = "authentik Embedded Outpost"
}

import {
  to = authentik_outpost.embedded
  id = data.authentik_outpost.embedded.id
}

resource "authentik_outpost" "embedded" {
  name = "authentik Embedded Outpost"
  type = "proxy"

  protocol_providers = [for p in authentik_provider_proxy.forward_auth : p.id]

  # service_connection conservé tel quel.
  lifecycle {
    ignore_changes = [service_connection]
  }
}
