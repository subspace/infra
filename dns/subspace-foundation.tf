resource "cloudflare_record" "subspace_foundation_1" {
  name    = "subspace.foundation"
  proxied = false
  ttl     = 3600
  type    = "A"
  value   = "192.64.119.47"
  zone_id = data.cloudflare_zone.subspace_foundation.id
}

resource "cloudflare_record" "subspace_foundation_www" {
  name    = "subspace.foundation"
  proxied = false
  ttl     = 3600
  type    = "A"
  value   = "192.64.119.47
  zone_id = data.cloudflare_zone.subspace_foundation.id
}

// mailserver records for subspace.foundation
resource "cloudflare_record" "mailserver_mx" {
  name     = "subspace.foundation"
  comment  = "MX record pointing to our preferred mailserver"
  priority = 1
  proxied  = false
  ttl      = 3600
  type     = "MX"
  value    = "smtp.google.com"
  zone_id  = data.cloudflare_zone.subspace_foundation.id
}
