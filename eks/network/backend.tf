terraform {
  cloud {
    organization = "subspace-sre"

    workspaces {
      name = "subspace-aws-managed-k8s"
    }
  }
}
