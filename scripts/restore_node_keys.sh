#!/bin/bash

# Check if jq is installed and install it if not.
check_jq() {
  if ! command -v jq &> /dev/null; then
    echo "jq not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y jq
  else
    echo "jq is already installed."
  fi
}

# Function to retrieve key-value pair from Hashicorp Vault
get_from_vault() {
  local node_name=$1

  local vault_endpoint="https://vault.eks.subspace.network/v1/secret/data/node-keys/${node_name}"
  local vault_token=$(base64 -d <<< ${VAULT_TOKEN})

  local response=$(curl -s -H "X-Vault-Token: ${vault_token}" "${vault_endpoint}")
  local key_value=$(echo "${response}" | jq -r '.data.data.key')

  echo "Retrieved key-value pair from Hashicorp Vault for node: ${node_name}"
  echo "${key_value}"
}

# Function to store key-value pair in .env file
store_in_env_file() {
  local node_name=$1
  local key_id=$2
  local key_value=$3

  echo "${node_id}=${node_name}" >> ".env"
  echo "peer_id=${key_id}" >> ".env"
  echo "node_key=${key_value}" >> ".env"

  echo "Stored key-value pair in .env file for node: ${node_name}"
}

# Check if node name is provided as an argument
if [ $# -eq 0 ]; then
  echo "Please provide the node name as an argument."
  exit 1
fi

node_name=$1

# Check and install jq if needed
check_jq

# Retrieve key-value pair from Hashicorp Vault
key_value=$(get_from_vault "${node_name}")

# Extract key_id and key_value from the retrieved key-value pair
key_id=$(echo "${key_value}" | awk -F'=' '{print $1}')
key_value=$(echo "${key_value}" | awk -F'=' '{print $2}')

# Store key_id and key_value in .env file
store_in_env_file "${node_name}" "${key_id}" "${key_value}"

echo "Key-value pair retrieval and storage completed for node: ${node_name}"
