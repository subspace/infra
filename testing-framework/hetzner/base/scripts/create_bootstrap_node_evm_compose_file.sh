#!/bin/bash

EXTERNAL_IP=`curl -s -4 https://ifconfig.me`

reserved_only=${1}
node_count=${2}
current_node=${3}
bootstrap_node_count=${4}
enable_domains=${5}

cat > ~/subspace/subspace/docker-compose.yml << EOF
version: "3.7"

volumes:
  archival_node_data: {}

services:
  dsn-bootstrap-node:
    build:
      context: .
      dockerfile: $HOME/subspace/subspace/Dockerfile-bootstrap-node
    image: \${REPO_ORG}/\${NODE_TAG}:latest
    restart: unless-stopped
    environment:
      - RUST_LOG=info
    ports:
      - "30533:30533"
    command:
      - start
      - "--keypair"
      - \${DSN_NODE_KEY}
      - "--listen-on"
      - /ip4/0.0.0.0/udp/30533/quic-v1
      - "--listen-on"
      - /ip4/0.0.0.0/tcp/30533
      - --protocol-version
      - \${GENESIS_HASH}
      - "--in-peers"
      - "1000"
      - "--out-peers"
      - "1000"
      - "--pending-in-peers"
      - "1000"
      - "--pending-out-peers"
      - "1000"
## comment to disable external addresses using IP format for now
#      - "--external-address"
#      - "/ip4/$EXTERNAL_IP/udp/30533/quic-v1"
#      - "--external-address"
#      - "/ip4/$EXTERNAL_IP/tcp/30533"
EOF

for (( i = 0; i < node_count; i++ )); do
  if [ "${current_node}" == "${i}" ]; then
    dsn_addr=$(sed -nr "s/NODE_${i}_SUBSPACE_MULTI_ADDR=//p" ~/subspace/dsn_bootstrap_node_keys.txt)
    echo "      - \"--external-address\"" >> ~/subspace/docker-compose.yml
    echo "      - \"${dsn_addr}\"" >> ~/subspace/docker-compose.yml
    dsn_addr=$(sed -nr "s/NODE_${i}_SUBSPACE_MULTI_ADDR_TCP=//p" ~/subspace/dsn_bootstrap_node_keys.txt)
    echo "      - \"--external-address\"" >> ~/subspace/docker-compose.yml
    echo "      - \"${dsn_addr}\"" >> ~/subspace/docker-compose.yml
  fi
done

for (( i = 0; i < node_count; i++ )); do
  if [ "${current_node}" != "${i}" ]; then
    dsn_addr=$(sed -nr "s/NODE_${i}_SUBSPACE_MULTI_ADDR=//p" ~/subspace/dsn_bootstrap_node_keys.txt)
    echo "      - \"--reserved-peers\"" >> ~/subspace/subspace/docker-compose.yml
    echo "      - \"${dsn_addr}\"" >> ~/subspace/subspace/docker-compose.yml
    echo "      - \"--bootstrap-nodes\"" >> ~/subspace/subspace/docker-compose.yml
    echo "      - \"${dsn_addr}\"" >> ~/subspace/subspace/docker-compose.yml
  fi
done

cat >> ~/subspace/subspace/docker-compose.yml << EOF
  archival-node:
    build:
      context: .
      dockerfile: $HOME/subspace/subspace/Dockerfile-node
    image: \${REPO_ORG}/node:latest
    volumes:
      - archival_node_data:/var/subspace:rw
    restart: unless-stopped
    ports:
      - "30333:30333/udp"
      - "30433:30433/udp"
      - "30333:30333/tcp"
      - "30433:30433/tcp"
      - "30334:30334/tcp"
      - "9615:9615"
    command: [
      "run",
      "--chain", "\${NETWORK_NAME}",
      "--base-path", "/var/subspace",
      "--state-pruning", "archive",
      "--blocks-pruning", "256",
      "--listen-on", "/ip4/0.0.0.0/tcp/30333",
## comment to disable dsn external addresses using IP format for now
#      "--dsn-external-address", "/ip4/$EXTERNAL_IP/udp/30433/quic-v1",
#      "--dsn-external-address", "/ip4/$EXTERNAL_IP/tcp/30433",
      "--node-key", "\${NODE_KEY}",
      "--in-peers", "1000",
      "--out-peers", "1000",
      "--dsn-in-connections", "1000",
      "--dsn-out-connections", "1000",
      "--dsn-pending-in-connections", "1000",
      "--dsn-pending-out-connections", "1000",
      "--prometheus-listen-on", "0.0.0.0:9615",
EOF

for (( i = 0; i < node_count; i++ )); do
  if [ "${current_node}" == "${i}" ]; then
    dsn_addr=$(sed -nr "s/NODE_${i}_SUBSTRATE_MULTI_ADDR=//p" ~/subspace/dsn_bootstrap_node_keys.txt)
    echo "      - \"--dsn-external-address\"" >> ~/subspace/docker-compose.yml
    echo "      - \"${dsn_addr}\"" >> ~/subspace/docker-compose.yml
    dsn_addr=$(sed -nr "s/NODE_${i}_SUBSTRATE_MULTI_ADDR_TCP=//p" ~/subspace/dsn_bootstrap_node_keys.txt)
    echo "      - \"--dsn-external-address\"" >> ~/subspace/docker-compose.yml
    echo "      - \"${dsn_addr}\"" >> ~/subspace/docker-compose.yml
  fi
done

for (( i = 0; i < bootstrap_node_count; i++ )); do
  addr=$(sed -nr "s/NODE_${i}_MULTI_ADDR=//p" ~/subspace/bootstrap_node_keys.txt)
    echo "      \"--reserved-nodes\", \"${addr}\"," >> ~/subspace/subspace/docker-compose.yml
    echo "      \"--bootstrap-nodes\", \"${addr}\"," >> ~/subspace/subspace/docker-compose.yml
done

for (( i = 0; i < dsn_bootstrap_node_count; i++ )); do
  dsn_addr=$(sed -nr "s/NODE_${i}_SUBSPACE_MULTI_ADDR=//p" ~/subspace/dsn_bootstrap_node_keys.txt)
  echo "      \"--dsn-reserved-peers\", \"${dsn_addr}\"," >> ~/subspace/subspace/docker-compose.yml
  echo "      \"--dsn-bootstrap-nodes\", \"${dsn_addr}\"," >> ~/subspace/subspace/docker-compose.yml
done

if [ "${reserved_only}" == true ]; then
    echo "      \"--reserved-only\"," >> ~/subspace/subspace/docker-compose.yml
fi

if [ "${enable_domains}" == "true" ]; then
    {
    # core domain
      echo '      "--",'
      echo '      "--domain-id", "${DOMAIN_ID}",'
      echo '      "--state-pruning", "archive",'
      echo '      "--blocks-pruning", "archive",'
      echo '      "--listen-on", "/ip4/0.0.0.0/tcp/30334",'
      echo '      "--rpc-cors", "all",'
      echo '      "--rpc-listen-on", "127.0.0.1:8944",'
    for (( i = 0; i <  node_count; i++ )); do
      addr=$(sed -nr "s/NODE_${i}_OPERATOR_MULTI_ADDR=//p" ~/subspace/node_keys.txt)
      echo "      \"--reserved-nodes\", \"${addr}\"," >> ~/subspace/docker-compose.yml
      echo "      \"--bootstrap-nodes\", \"${addr}\"," >> ~/subspace/docker-compose.yml
    done

    }  >> ~/subspace/subspace/docker-compose.yml
fi

echo '    ]' >> ~/subspace/subspace/docker-compose.yml
