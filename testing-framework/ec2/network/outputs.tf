//output
output "node-ipv4-addresses" {
  value       = module.network.node_public_ip
  description = "Subspace node IPv4 Addresses"
}

output "farmer-node-ipv4-addresses" {
  value       = module.network.farmer_node_public_ip
  description = "Farmer node IPv4 Addresses"
}

output "bootstrap-node-ipv4-addresses" {
  value       = module.network.bootstrap_node_public_ip
  description = "Bootstrap node IPv4 Addresses"
}

output "bootstrap-node-evm-ipv4-addresses" {
  value       = module.network.bootstrap_node_evm_public_ip
  description = "Bootstrap node evm IPv4 Addresses"
}

output "bootstrap-node-autoid-ipv4-addresses" {
  value       = module.network.bootstrap_node_autoid_public_ip
  description = "Bootstrap node autoid IPv4 Addresses"
}

output "domain-node-ipv4-addresses" {
  value       = module.network.domain_node_public_ip
  description = "Domain node IPv4 Addresses"
}

# Output the operator_peer_evm_multiaddr value
output "operator_peer_evm_multiaddr" {
  value = data.external.operator_peer_evm_multiaddr.result
}

# Output the operator_peer_autoid_multiaddr value
output "operator_peer_autoid_multiaddr" {
  value = data.external.operator_peer_autoid_multiaddr.result
}
