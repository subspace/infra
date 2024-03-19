// Output Variables

output "bootstrap_node_server_id" {
  value = module.bootstrap_node.*.id
}

output "bootstrap_node_public_ip" {
  value = module.bootstrap_node.*.public_ip
}

output "bootstrap_node_private_ip" {
  value = module.bootstrap_node.*.private_ip
}

output "bootstrap_node_ami" {
  value = module.bootstrap_node.*.ami
}

output "bootstrap_node_evm_server_id" {
  value = module.bootstrap_node_evm.*.id
}

output "bootstrap_node_evm_public_ip" {
  value = module.bootstrap_node_evm.*.public_ip
}

output "bootstrap_node_evm_private_ip" {
  value = module.bootstrap_node_evm.*.private_ip
}

output "bootstrap_node_evm_ami" {
  value = module.bootstrap_node_evm.*.ami
}

output "full_node_server_id" {
  value = module.full_node.*.id
}

output "full_node_private_ip" {
  value = module.full_node.*.private_ip
}

output "full_node_public_ip" {
  value = module.full_node.*.public_ip
}

output "full_node_ami" {
  value = module.full_node.*.ami
}


output "rpc_node_server_id" {
  value = module.rpc_node.*.id
}

output "rpc_node_private_ip" {
  value = module.rpc_node.*.private_ip
}

output "rpc_node_public_ip" {
  value = module.rpc_node.*.public_ip
}

output "rpc_node_ami" {
  value = module.rpc_node.*.ami
}


output "domain_node_server_id" {
  value = module.domain_node.*.id
}

output "domain_node_private_ip" {
  value = module.domain_node.*.private_ip
}

output "domain_node_public_ip" {
  value = module.domain_node.*.public_ip
}

output "domain_node_ami" {
  value = module.domain_node.*.ami
}


output "farmer_node_server_id" {
  value = module.farmer_node.*.id
}

output "farmer_node_private_ip" {
  value = module.farmer_node.*.private_ip
}

output "farmer_node_public_ip" {
  value = module.farmer_node.*.public_ip
}

output "farmer_node_ami" {
  value = module.farmer_node.*.ami
}

output "dns-records" {
  value = [
    cloudflare_record.bootstrap.*.hostname,
    cloudflare_record.rpc.*.hostname,
    cloudflare_record.core-domain.*.hostname,
    cloudflare_record.nova.*.hostname,
  ]
}
