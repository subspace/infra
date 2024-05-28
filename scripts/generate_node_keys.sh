#!/bin/bash

# Function to check if subkey is installed
check_subkey() {
  if ! command -v subkey &> /dev/null; then
    echo "subkey not found. Installing..."
    curl https://getsubstrate.io -sSf | bash -s -- --fast
    cargo install --force subkey --git https://github.com/paritytech/substrate --locked
  else
    echo "subkey is already installed."
  fi
}

# Function to generate node key and store in a file
# Generate node key and store in a file
generate_node_key() {
  local node_type=$1
  local node_index=$2

  local key_file="${node_type}-${node_index}.key"
  subkey generate-node-key 2>&1 | tee "${key_file}"
  echo "Generated node key for ${node_type}-${node_index}"
}

# Function to add key-value pair to Hashicorp Vault
add_to_vault() {
  local key_file=$1

  local key_id=$(sed -n '1p' "${key_file}")
  local key_value=$(sed -n '2p' "${key_file}")
  local node_name=$(basename "${key_file}" .key)

  # Add key-value pair to Hashicorp Vault using API call
  local vault_endpoint="https://vault.eks.subspace.network/v1/secret/data/node-keys/${node_name}"
  local vault_token=$(base64 -d <<< ${VAULT_TOKEN})

  curl -X POST -H "X-Vault-Token: ${vault_token}" -d "{\"data\": {\"key\": \"${key_id}=${key_value}\"}}" "${vault_endpoint}"
  echo "Added key-value pair to Hashicorp Vault: ${node_name} = ${key_id}=${key_value}"
}

# Check and install subkey if needed
check_subkey

# Generate node keys for bootstrap nodes
for i in {0..1}; do
  generate_node_key "bootstrap" "${i}"
done

# Generate node keys for rpc nodes
for i in {0..1}; do
  generate_node_key "rpc" "${i}"
done

# Generate node keys for domain nodes
for i in {0..1}; do
  generate_node_key "domain" "${i}"
done

# Generate node key for farmer node
generate_node_key "farmer" "0"

# Generate node keys for nova-bootstrap nodes
for i in {0..1}; do
  generate_node_key "nova-bootstrap" "${i}"
done

# Add generated keys to Hashicorp Vault
for key_file in *.key; do
  add_to_vault "${key_file}"
done

echo "Node key generation and Vault storage completed."
