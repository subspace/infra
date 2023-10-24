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


output "node_server_id" {
  value = aws_instance.node.*.id
}

output "node_private_ip" {
  value = aws_instance.node.*.private_ip
}

output "node_public_ip" {
  value = aws_instance.node.*.public_ip
}

output "node_ami" {
  value = aws_instance.node.*.ami
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