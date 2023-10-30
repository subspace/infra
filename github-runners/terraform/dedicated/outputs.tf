// Output Variables

output "ingress_rules" {
  value = aws_security_group.allow_runner.*.ingress
}

output "linux_x86_64_runner_server_id" {
  value = aws_instance.linux_x86_64_runner.*.id
}

output "linux_x86_64_runner_public_ip" {
  value = aws_instance.linux_x86_64_runner.*.public_ip
}

output "linux_x86_64_runner_private_ip" {
  value = aws_instance.linux_x86_64_runner.*.private_ip
}

output "linux_x86_64_runner_ami" {
  value = aws_instance.linux_x86_64_runner.*.ami
}


output "linux_arm64_runner_server_id" {
  value = aws_instance.linux_arm64_runner.*.id
}

output "linux_arm64_runner_private_ip" {
  value = aws_instance.linux_arm64_runner.*.private_ip
}

output "linux_arm64_runner_public_ip" {
  value = aws_instance.linux_arm64_runner.*.public_ip
}

output "linux_arm64_runner_ami" {
  value = aws_instance.linux_arm64_runner.*.ami
}


output "mac_x86_64_runner_server_id" {
  value = aws_instance.mac_x86_64_runner.*.id
}

output "mac_x86_64_runner_private_ip" {
  value = aws_instance.mac_x86_64_runner.*.private_ip
}

output "mac_x86_64_runner_public_ip" {
  value = aws_instance.mac_x86_64_runner.*.public_ip
}

output "mac_x86_64_runner_ami" {
  value = aws_instance.mac_x86_64_runner.*.ami
}


output "mac_arm64_runner_server_id" {
  value = aws_instance.mac_arm64_runner.*.id
}

output "mac_arm64_runner_private_ip" {
  value = aws_instance.mac_arm64_runner.*.private_ip
}

output "mac_arm64_runner_public_ip" {
  value = aws_instance.mac_arm64_runner.*.public_ip
}

output "mac_arm64_runner_ami" {
  value = aws_instance.mac_arm64_runner.*.ami
}

output "windows_x86_64_runner_server_id" {
  value = aws_instance.windows_x86_64_runner.*.id
}

output "windows_x86_64_runner_private_ip" {
  value = aws_instance.windows_x86_64_runner.*.private_ip
}

output "windows_x86_64_runner_public_ip" {
  value = aws_instance.windows_x86_64_runner.*.public_ip
}

output "windows_x86_64_runner_ami" {
  value = aws_instance.windows_x86_64_runner.*.ami
}
