terraform {
  cloud {
    organization = "subspace-sre"

    workspaces {
      name = "github-runners-ephemeral-win"
    }
  }
}
