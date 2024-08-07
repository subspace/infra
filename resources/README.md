# Terraform-Based Deployment for Subspace Infrastructure

## Introduction

Welcome to the Terraform AWS framework for Subspace's networks. This framework does infrastructure provisioning using Terraform and deployments with docker & docker compose.

## Prerequisites

Before using this framework, ensure you have the following installed:

- [Terraform (latest version recommended)](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Git
- [AWS CLI (required when deploying on AWS only)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)

## Installation via Terraform

We use **Terraform** and **AWS** to provision the infrastructure.

Clone the repository and navigate to the testing framework directory **resources**:

### Terraform Resources Folder Structure:

```
.
├── README.md
├── devnet
│   ├── backend.tf
│   ├── common.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terrafrom.tfvars.example
│   └── variables.tf
├── gemini-3f
│   ├── backend.tf
│   ├── common.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terrafrom.tfvars.example
│   └── variables.tf
├── gemini-3g
│   ├── backend.tf
│   ├── common.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terrafrom.tfvars.example
│   └── variables.tf
├── network-primitives
│   ├── ami.tf
│   ├── bootstrap_node_evm_provisioner.tf
│   ├── bootstrap_node_provisioner.tf
│   ├── configs
│   │   └── prometheus.yml
│   ├── dns.tf
│   ├── domain_node_provisioner.tf
│   ├── farmer_node_provisioner.tf
│   ├── rpc-squid_node_provisioner.tf
│   ├── instances.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── rpc_node_provisioner.tf
│   ├── scripts
│   │   ├── create_bootstrap_node_compose_file.sh
│   │   ├── create_bootstrap_node_evm_compose_file.sh
│   │   ├── create_domain_node_compose_file.sh
│   │   ├── create_farmer_node_compose_file.sh
│   │   ├── create_rpc-squid_node_compose_file.sh
│   │   ├── create_rpc_node_compose_file.sh
│   │   ├── installer.sh
│   │   └── prune_docker_system.sh
│   └── variables.tf
└── telemetry
    └── ec2
        ├── base
        └── modules
```

## Getting started.

- Go to **resources/<network_name>/**
- rename the terraform.tfvars.example file inside the child module to terraform.tfvars.
- modify the main.tf file if any further changes are needed to customize
- Add your personal AWS access and secret in the terraform.tfvars file
- gather the necessary deployment ssh keys i.e deployer.pem from bitwarden and set the `private_key_path` variable to the location on the filesystem.
- populate the empty variables with the correct values in the terraform.tfvars file

- Then you are ready to follow instructions to **init** terraform, **add resources**, **plan** the resource deployment and **apply** the resource deployments for the respective provider.

## Generate Node keys

Each network will need it's own keys, which you can gather from bitwarden, and extract the zip folder into **resources/<network_name>/**. The files should be named the following.

```
.
├── bootstrap_node_evm_keys.txt
├── bootstrap_node_keys.txt
├── domain_node_keys.txt
├── dsn_bootstrap_node_keys.txt
├── farmer_node_keys.txt
├── rpc-squid_node_keys.txt
├── keystore
├── relayer_ids.txt
└── rpc_node_keys.txt
```

## Deploy resources.

1. Go to **resources/<network_name>/** directory and run the following commands to init terraform:

   ```
   terraform init
   ```

   You are ready to run the **plan** and **apply** command with this.

2. Run the **plan** command with the variable values passed in to see Terraform's steps to deploy the project resources.

   ```SH
   terraform plan -var-file=terraform.tfvars -out current-plan.tfplan
   ```

3. Run the **apply** command with the generated **current-plan.tfplan**.

   ```SH
   terraform apply current-plan.tfplan
   ```

Terraform will apply changes and generate/update the **.tfstate** file.
Be aware that state files can contain sensitive information. Do not expose it to the public repository.

## Installation via Github Actions

To deploy a network, either gemini or devnet with Github CI/CD the workflows `.github/workflows/gemini_<network>_main_deploy.yml` and `.github/workflows/devnet_main_deploy.yml` can be triggered for AWS deployment.

The workflow will decrypt the terraform.tfvars file in the working directory of the terraform resource, which is encrypted with AES-256 using the transcrypt encryption/decryption tool. This prevents leaking of sensitive data.

Additionally, an SSH deployment key is needed to work with the terraform provisioner `remote-exec`, which should also be included in the working directory of the terraform resource. This file should be encrypted with transcrypt for security,
and the workflow will decrypt the file on each run.

## Workflow Steps

1. Go to _Actions_ tab of the repository
2. Select the workflow you want to execute
3. In the right panel click on **Run workflow** button to drop down the options.
4. Run the workflow
