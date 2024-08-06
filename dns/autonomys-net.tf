resource "cloudflare_record" "autonomys_net_1" {
  name    = "autonomys.net"
  proxied = false
  ttl     = 3600
  type    = "A"
  value   = "52.223.52.2"
  zone_id = data.cloudflare_zone.autonomys_net.id
}

resource "cloudflare_record" "autonomys_net_2" {
  name    = "autonomys.net"
  proxied = false
  ttl     = 3600
  type    = "A"
  value   = "35.71.142.77"
  zone_id = data.cloudflare_zone.autonomys_net.id
}

resource "cloudflare_record" "autonomys_net_www" {
  name    = "www"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  value   = "sites.framer.app"
  zone_id = data.cloudflare_zone.autonomys_net.id
}

resource "cloudflare_record" "autonomys_net_academy" {
  name    = "academy"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  value   = "a80ab473c4-hosting.gitbook.io"
  zone_id = data.cloudflare_zone.autonomys_net.id
}

// mailserver records for autonomys.net
resource "cloudflare_record" "mailserver_mx_1" {
  name     = "autonomys.net"
  comment  = "MX record pointing to our preferred mailserver"
  priority = 1
  proxied  = false
  ttl      = 3600
  type     = "MX"
  value    = "aspmx.l.google.com"
  zone_id  = data.cloudflare_zone.autonomys_net.id
}

resource "cloudflare_record" "mailserver_mx_2" {
  name     = "autonomys.net"
  comment  = "MX record pointing to our preferred mailserver"
  priority = 5
  proxied  = false
  ttl      = 3600
  type     = "MX"
  value    = "alt1.aspmx.l.google.com"
  zone_id  = data.cloudflare_zone.autonomys_net.id
}

resource "cloudflare_record" "mailserver_mx_3" {
  name     = "autonomys.net"
  comment  = "MX record pointing to our preferred mailserver"
  priority = 5
  proxied  = false
  ttl      = 3600
  type     = "MX"
  value    = "alt2.aspmx.l.google.com"
  zone_id  = data.cloudflare_zone.autonomys_net.id
}

resource "cloudflare_record" "mailserver_mx_4" {
  name     = "autonomys.net"
  comment  = "MX record pointing to our preferred mailserver"
  priority = 10
  proxied  = false
  ttl      = 3600
  type     = "MX"
  value    = "alt3.aspmx.l.google.com"
  zone_id  = data.cloudflare_zone.autonomys_net.id
}

resource "cloudflare_record" "mailserver_mx_5" {
  name     = "autonomys.net"
  comment  = "MX record pointing to our preferred mailserver"
  priority = 10
  proxied  = false
  ttl      = 3600
  type     = "MX"
  value    = "alt4.aspmx.l.google.com"
  zone_id  = data.cloudflare_zone.autonomys_net.id
}
