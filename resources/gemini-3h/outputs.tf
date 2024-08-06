//output
output "rpc-squid-node-ipv4-addresses" {
  value       = module.gemini-3h.rpc-squid_node_public_ip
  description = "RPC squid node IPv4 Addresses"
}

output "nova-squid-node-ipv4-addresses" {
  value       = module.gemini-3h.nova-squid_node_public_ip
  description = "Nova Squid node IPv4 Addresses"
}

output "farmer-node-ipv4-addresses" {
  value       = module.gemini-3h.farmer_node_public_ip
  description = "Farmer node IPv4 Addresses"
}

output "bootstrap-node-ipv4-addresses" {
  value       = module.gemini-3h.bootstrap_node_public_ip
  description = "Bootstrap node IPv4 Addresses"
}

output "bootstrap-node-evm-ipv4-addresses" {
  value       = module.gemini-3h.bootstrap_node_evm_public_ip
  description = "EVM Bootstrap node IPv4 Addresses"
}

output "bootstrap-node-autoid-ipv4-addresses" {
  value       = module.gemini-3h.bootstrap_node_autoid_public_ip
  description = "AutoID Bootstrap node IPv4 Addresses"
}

output "domain-node-ipv4-addresses" {
  value       = module.gemini-3h.domain_node_public_ip
  description = "Domain node IPv4 Addresses"
}

output "autoid-node-ipv4-addresses" {
  value       = module.gemini-3h.autoid_node_public_ip
  description = "AutoID node IPv4 Addresses"
}

output "rpc-node-ipv4-addresses" {
  value       = module.gemini-3h.rpc_node_public_ip
  description = "RPC node IPv4 Addresses"
}

output "pot_external_entropy" {
  value       = var.pot_external_entropy
  description = "Pot external entropy"

}
