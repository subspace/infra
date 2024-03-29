# EKS managed node group - bottlerocket
output "eks_mng_bottlerocket_no_op" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_bottlerocket_no_op.user_data)
}

output "eks_mng_bottlerocket_additional" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_bottlerocket_additional.user_data)
}

output "eks_mng_bottlerocket_custom_ami" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_bottlerocket_custom_ami.user_data)
}

output "eks_mng_bottlerocket_custom_template" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_bottlerocket_custom_template.user_data)
}
