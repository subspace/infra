// Output Variables

output "bootstrap_node_server_id" {
  value = aws_instance.bootstrap_node.*.id
}

output "bootstrap_node_public_ip" {
  value = aws_instance.bootstrap_node.*.public_ip
}

output "bootstrap_node_private_ip" {
  value = aws_instance.bootstrap_node.*.private_ip
}

output "bootstrap_node_ami" {
  value = aws_instance.bootstrap_node.*.ami
}

output "bootstrap_node_evm_server_id" {
  value = aws_instance.bootstrap_node_evm.*.id
}

output "bootstrap_node_evm_public_ip" {
  value = aws_instance.bootstrap_node_evm.*.public_ip
}

output "bootstrap_node_evm_private_ip" {
  value = aws_instance.bootstrap_node_evm.*.private_ip
}

output "bootstrap_node_evm_ami" {
  value = aws_instance.bootstrap_node_evm.*.ami
}

output "bootstrap_node_autoid_server_id" {
  value = aws_instance.bootstrap_node_autoid.*.id
}

output "bootstrap_node_autoid_public_ip" {
  value = aws_instance.bootstrap_node_autoid.*.public_ip
}

output "bootstrap_node_autoid_private_ip" {
  value = aws_instance.bootstrap_node_autoid.*.private_ip
}

output "bootstrap_node_autoid_ami" {
  value = aws_instance.bootstrap_node_autoid.*.ami
}

output "rpc_squid_node_server_id" {
  value = aws_instance.rpc_squid_node.*.id
}

output "rpc_squid_node_private_ip" {
  value = aws_instance.rpc_squid_node.*.private_ip
}

output "rpc_squid_node_public_ip" {
  value = aws_instance.rpc_squid_node.*.public_ip
}

output "rpc_squid_node_ami" {
  value = aws_instance.rpc_squid_node.*.ami
}

output "nova_squid_node_server_id" {
  value = aws_instance.nova_squid_node.*.id
}

output "nova_squid_node_private_ip" {
  value = aws_instance.nova_squid_node.*.private_ip
}

output "nova_squid_node_public_ip" {
  value = aws_instance.nova_squid_node.*.public_ip
}

output "nova_squid_node_ami" {
  value = aws_instance.nova_squid_node.*.ami
}


output "rpc_node_server_id" {
  value = aws_instance.rpc_node.*.id
}

output "rpc_node_private_ip" {
  value = aws_instance.rpc_node.*.private_ip
}

output "rpc_node_public_ip" {
  value = aws_instance.rpc_node.*.public_ip
}

output "rpc_node_ami" {
  value = aws_instance.rpc_node.*.ami
}


output "domain_node_server_id" {
  value = aws_instance.domain_node.*.id
}

output "domain_node_private_ip" {
  value = aws_instance.domain_node.*.private_ip
}

output "domain_node_public_ip" {
  value = aws_instance.domain_node.*.public_ip
}

output "domain_node_ami" {
  value = aws_instance.domain_node.*.ami
}

output "autoid_node_server_id" {
  value = aws_instance.autoid_node.*.id
}

output "autoid_node_private_ip" {
  value = aws_instance.autoid_node.*.private_ip
}

output "autoid_node_public_ip" {
  value = aws_instance.autoid_node.*.public_ip
}

output "autoid_node_ami" {
  value = aws_instance.autoid_node.*.ami
}


output "farmer_node_server_id" {
  value = aws_instance.farmer_node.*.id
}

output "farmer_node_private_ip" {
  value = aws_instance.farmer_node.*.private_ip
}

output "farmer_node_public_ip" {
  value = aws_instance.farmer_node.*.public_ip
}

output "farmer_node_ami" {
  value = aws_instance.farmer_node.*.ami
}

output "dns-records" {
  value = [
    cloudflare_record.bootstrap.*.hostname,
    cloudflare_record.rpc.*.hostname,
    cloudflare_record.rpc-squid.*.hostname,
    cloudflare_record.nova-squid-rpc.*.hostname,
    cloudflare_record.nova.*.hostname,
    cloudflare_record.autoid.*.hostname,
  ]
}
