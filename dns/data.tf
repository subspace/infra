// ## Subspace.network zone ##
data "cloudflare_zone" "subspace_network" {
  name = "subspace.network"
}

// ## Subspace.net zone ##
data "cloudflare_zone" "subspace_net" {
  name = "subspace.net"
}

// ## continuim.cc zone ##
data "cloudflare_zone" "continuim_cc" {
  name = "continuim.cc"
}

// ## continuum.co zone ##
data "cloudflare_zone" "continuum_co" {
  name = "continuum.co"
}

// ## autonomys.net zone ##
data "cloudflare_zone" "autonomys_net" {
  name = "autonomys.net"
}

// ## autonomys.xyz zone ##
data "cloudflare_zone" "autonomys_xyz" {
  name = "autonomys.xyz"
}

// ## subspace.foundation zone ##
data "cloudflare_zone" "subspace_foundation" {
  name = "subspace.foundation"
}
