#!/bin/bash

docker pull ghcr.io/subspace/node:gemini-3d-2023-may-15
node_count=${1}
output_file=${2}
port=${3:-30333}
if [ -s "${output_file}" ]; then
    echo "Node keys exists..."
    exit 0
fi
ips=$(echo "$NODE_PUBLIC_IPS" | awk -F, '{for(i=1;i<=NF;i++) print $i}')
ips=( ${ips} )
echo -n > "${output_file}"
echo "Generating node keys..."
for (( i = 0; i < node_count; i++ )); do
    data="$(docker run --rm ghcr.io/subspace/node:gemini-3d-2023-may-15 key generate-node-key 2>&1)"
    peer_id=$(echo "$data" | sed '2q;d')
    node_key=$(echo "$data" | sed '3q;d')
    {
      echo "NODE_${i}_PEER_ID=${peer_id}"
      echo "NODE_${i}_KEY=${node_key}"
      echo "NODE_${i}_MULTI_ADDR=/ip4/${ips[${i}]}/tcp/${port}/p2p/${peer_id}"
    } >> "${output_file}"
done
echo "Done."
