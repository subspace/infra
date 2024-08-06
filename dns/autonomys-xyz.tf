resource "cloudflare_record" "autonomys_xyz_1" {
  name    = "autonomys.xyz"
  proxied = false
  ttl     = 3600
  type    = "A"
  value   = "52.223.52.2"
  zone_id = data.cloudflare_zone.autonomys_xyz.id
}

resource "cloudflare_record" "autonomys_xyz_2" {
  name    = "autonomys.xyz"
  proxied = false
  ttl     = 3600
  type    = "A"
  value   = "35.71.142.77"
  zone_id = data.cloudflare_zone.autonomys_xyz.id
}

resource "cloudflare_record" "autonomys_xyz_www" {
  name    = "www"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  value   = "sites.framer.app"
  zone_id = data.cloudflare_zone.autonomys_xyz.id
}

resource "cloudflare_record" "autonomys_xyz_astral" {
  name    = "astral"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  value   = "astral-prod.netlify.app"
  zone_id = data.cloudflare_zone.autonomys_xyz.id
}

resource "cloudflare_record" "autonomys_xyz_explorer" {
  name    = "explorer"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  value   = "astral-prod.netlify.app"
  zone_id = data.cloudflare_zone.autonomys_xyz.id
}

resource "cloudflare_record" "autonomys_xyz_academy" {
  name    = "academy"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  value   = "a80ab473c4-hosting.gitbook.io"
  zone_id = data.cloudflare_zone.autonomys_xyz.id
}

// mailserver records for autonomys.xyz
resource "cloudflare_record" "mailserver_mx" {
  name     = "autonomys.xyz"
  comment  = "MX record pointing to our preferred mailserver"
  priority = 1
  proxied  = false
  ttl      = 3600
  type     = "MX"
  value    = "smtp.google.com"
  zone_id  = data.cloudflare_zone.autonomys_xyz.id
}

resource "cloudflare_record" "dmarc" {
  zone_id = data.cloudflare_zone.autonomys_xyz.id
  name    = "_dmarc"
  type    = "TXT"
  value   = "v=DMARC1; p=quarantine; rua=mailto:dmarc@autonomys.xyz; ruf=mailto:dmarc@autonomys.xyz; aspf=r; adkim=r;"
  ttl     = 3600
}

resource "cloudflare_record" "spf" {
  zone_id = data.cloudflare_zone.autonomys_xyz.id
  name    = "@"
  type    = "TXT"
  value   = "v=spf1 a mx include:_spf.google.com include:subspace.network ~all"
  ttl     = 3600
}

// autonomys block explorer
resource "cloudflare_record" "block_explorer" {
  comment = "Subspace block explorer"
  name    = "explorer"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  value   = "astral-prod.netlify.app"
  zone_id = data.cloudflare_zone.subspace_network.id
}

// autonomys block explorer Astral
resource "cloudflare_record" "block_explorer_astral" {
  comment = "Subspace block explorer"
  name    = "astral"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  value   = "astral-prod.netlify.app"
  zone_id = data.cloudflare_zone.subspace_network.id
}

resource "cloudflare_record" "_27e027657b943bc5de8249fa279f49df_safe_autonomys_xyz"
  zone_id = data.cloudflare_zone.autonomys_xyz.id
  name    = "_27e027657b943bc5de8249fa279f49df.safe.autonomys.xyz"
  type    = "CNAME"
  value   = "_e005d46e6b63e60cd27883cb1aa573e6.sdgjtdhdhz.acm-validations.aws"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "_0cb51155ee81f2362bd25953737affa9_staging_safe_autonomys_xyz"
  zone_id = data.cloudflare_zone.autonomys_xyz.id
  name    = "_0cb51155ee81f2362bd25953737affa9.staging.safe.autonomys.xyz"
  type    = "CNAME"
  value   = "_58716a844b97a4c99143680bca87b061.sdgjtdhdhz.acm-validations.aws"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "staging_wallet_web_ui" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "staging.safe"
  value   = "d2r0ylf7cfvofa.cloudfront.net"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "staging_config_service" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "config.staging.safe"
  value   = "safe-autonomys-1281125464.us-east-1.elb.amazonaws.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "staging_gateway_service" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "gateway.staging.safe"
  value   = "safe-autonomys-1281125464.us-east-1.elb.amazonaws.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "staging_events_service" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "events.staging.safe"
  value   = "safe-autonomys-1281125464.us-east-1.elb.amazonaws.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "staging_transaction_testnet_service" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "transaction-testnet.staging.safe"
  value   = "safe-autonomys-1281125464.us-east-1.elb.amazonaws.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "staging_flower_transaction_testnet_service" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "flower-transaction-testnet.staging.safe"
  value   = "safe-autonomys-1281125464.us-east-1.elb.amazonaws.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "staging_static_assets" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "assets.staging.safe"
  value   = "d1xizeqd8g84j.cloudfront.net"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "prod_wallet_web_ui" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "safe"
  value   = "d5w1d4ch1mqvo.cloudfront.net"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "prod_config_service" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "config.safe"
  value   = "safe-autonomys-1907842251.us-east-1.elb.amazonaws.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "prod_gateway_service" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "gateway.safe"
  value   = "safe-autonomys-1907842251.us-east-1.elb.amazonaws.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "prod_events_service" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "events.safe"
  value   = "safe-autonomys-1907842251.us-east-1.elb.amazonaws.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "prod_transaction_testnet_service" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "transaction-testnet.safe"
  value   = "safe-autonomys-1907842251.us-east-1.elb.amazonaws.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "prod_flower_transaction_testnet_service" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "flower-transaction-testnet.safe"
  value   = "safe-autonomys-1907842251.us-east-1.elb.amazonaws.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "prod_static_assets" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "assets.safe"
  value   = "d2ymdwbs6umczt.cloudfront.net"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

resource "cloudflare_record" "prod_status_page" {
  zone_id = data.cloudflare_zone.subspace_network.id
  name    = "status.safe"
  value   = "stats.uptimerobot.com"
  type    = "CNAME"
  ttl     = 1 # Auto
  proxied = false
}

# Production CAA Records
resource "cloudflare_record" "caa_prod_root" {
  zone_id = var.cloudflare_zone_id
  name    = "safe.autonomys.xyz"
  type    = "CAA"
  value   = "0 issue amazon.com"
  ttl     = 3600
}

resource "cloudflare_record" "caa_prod_wildcard" {
  zone_id = var.cloudflare_zone_id
  name    = "*.safe.autonomys.xyz"
  type    = "CAA"
  value   = "0 issue amazon.com"
  ttl     = 3600
}

# Staging CAA Records
resource "cloudflare_record" "caa_staging_root" {
  zone_id = var.cloudflare_zone_id
  name    = "staging.safe.autonomys.xyz"
  type    = "CAA"
  value   = "0 issue amazon.com"
  ttl     = 3600
}

resource "cloudflare_record" "caa_staging_wildcard" {
  zone_id = var.cloudflare_zone_id
  name    = "*.staging.safe.autonomys.xyz"
  type    = "CAA"
  value   = "0 issue amazon.com"
  ttl     = 3600
}
