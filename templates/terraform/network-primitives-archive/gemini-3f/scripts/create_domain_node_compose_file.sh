#!/bin/bash

EXTERNAL_IP=`curl -s -4 https://ifconfig.me`

cat > ~/subspace/docker-compose.yml << EOF
version: "3.7"

volumes:
  archival_node_data: {}
  vmagentdata: {}

networks:
  traefik-proxy:
    external: true

services:
  vmagent:
    container_name: vmagent
    image: victoriametrics/vmagent:latest
    depends_on:
      - "archival-node"
    ports:
      - 8429:8429
    volumes:
      - vmagentdata:/vmagentdata
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    command:
      - "--httpListenAddr=0.0.0.0:8429"
      - "--promscrape.config=/etc/prometheus/prometheus.yml"
      - "--remoteWrite.url=http://vmetrics.subspace.network:8428/api/v1/write"

  agent:
    container_name: newrelic-infra
    image: newrelic/infrastructure:latest
    cap_add:
      - SYS_PTRACE
    network_mode: bridge
    pid: host
    privileged: true
    volumes:
      - "/:/host:ro"
      - "/var/run/docker.sock:/var/run/docker.sock"
    environment:
      NRIA_LICENSE_KEY: "\${NR_API_KEY}"
      NRIA_DISPLAY_NAME: "\${NETWORK_NAME}-domain-node-\${NODE_ID}"
    restart: unless-stopped

 # caddy reverse proxy with automatic tls management using let encrypt
  caddy:
    image: lucaslorentz/caddy-docker-proxy:latest
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    environment:
      - CADDY_INGRESS_NETWORKS=subspace_default
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - caddy_data:/data
    ports:
      - 80:80
      - 443:443
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./letsencrypt:/letsencrypt

  archival-node:
    image: ghcr.io/\${NODE_ORG}/node:\${NODE_TAG}
    volumes:
      - archival_node_data:/var/subspace:rw
    restart: unless-stopped
    ports:
      - "30333:30333"
      - "30433:30433"
      - "40333:40333"
      - "9615:9615"
    labels:
      caddy_0: \${DOMAIN_PREFIX}.\${NETWORK_NAME}.subspace.network
      caddy_0.handle_path_0: /ws
      caddy_0.handle_path_0.reverse_proxy: "{{upstreams 8944}}"
    logging:
      driver: loki
      options:
        loki-url: "https://logging.subspace.network/loki/api/v1/push"
    command: [
      "--chain", "\${NETWORK_NAME}",
      "--base-path", "/var/subspace",
      "--execution", "wasm",
#      "--enable-subspace-block-relay",
      "--state-pruning", "archive",
      "--blocks-pruning", "archive",
      "--listen-addr", "/ip4/0.0.0.0/tcp/30333",
      "--dsn-external-address", "/ip4/$EXTERNAL_IP/tcp/30433",
#      "--piece-cache-size", "\${PIECE_CACHE_SIZE}",
      "--node-key", "\${NODE_KEY}",
      "--rpc-cors", "all",
      "--rpc-external",
      "--in-peers", "500",
      "--out-peers", "250",
      "--in-peers-light", "500",
      "--rpc-max-connections", "10000",
      "--prometheus-port", "9615",
      "--prometheus-external",
EOF

reserved_only=${1}
node_count=${2}
current_node=${3}
bootstrap_node_count=${4}
dsn_bootstrap_node_count=${4}
bootstrap_node_evm_count=${5}
enable_domains=${6}
domain_id=${7}

for (( i = 0; i < bootstrap_node_count; i++ )); do
  addr=$(sed -nr "s/NODE_${i}_MULTI_ADDR=//p" ~/subspace//bootstrap_node_keys.txt)
  echo "      \"--reserved-nodes\", \"${addr}\"," >> ~/subspace/docker-compose.yml
  echo "      \"--bootnodes\", \"${addr}\"," >> ~/subspace/docker-compose.yml
done

for (( i = 0; i < dsn_bootstrap_node_count; i++ )); do
  dsn_addr=$(sed -nr "s/NODE_${i}_SUBSPACE_MULTI_ADDR=//p" ~/subspace/dsn_bootstrap_node_keys.txt)
  echo "      \"--dsn-reserved-peers\", \"${dsn_addr}\"," >> ~/subspace/docker-compose.yml
  echo "      \"--dsn-bootstrap-nodes\", \"${dsn_addr}\"," >> ~/subspace/docker-compose.yml
done

if [ "${reserved_only}" == "true" ]; then
    echo "      \"--reserved-only\"," >> ~/subspace/docker-compose.yml
fi

if [ "${enable_domains}" == "true" ]; then
  {
    # core domain
    echo '      "--",'
    echo '      "--chain=${NETWORK_NAME}",'
    #  echo '      "--enable-subspace-block-relay",'
    echo '      "--state-pruning", "archive",'
    echo '      "--blocks-pruning", "archive",'
    echo '      "--domain-id", "${DOMAIN_ID}",'
    echo '      "--operator",'
    echo '      "--keystore-path", "/var/subspace/keystore",'
    echo '      "--base-path", "/var/subspace/core_${DOMAIN_LABEL}_${DOMAIN_ID}_domain",'
    echo '      "--listen-addr", "/ip4/0.0.0.0/tcp/40333",'
    echo '      "--rpc-cors", "all",'
    echo '      "--rpc-port", "8944",'
    echo '      "--unsafe-rpc-external",'
    echo '      "--relayer-id=${RELAYER_DOMAIN_ID}",'

    for (( i = 0; i < bootstrap_node_evm_count; i++ )); do
      addr=$(sed -nr "s/NODE_${i}_MULTI_ADDR=//p" ~/subspace/bootstrap_node_evm_keys.txt)
      echo "      \"--reserved-nodes\", \"${addr}\"," >> ~/subspace/docker-compose.yml
      echo "      \"--bootnodes\", \"${addr}\"," >> ~/subspace/docker-compose.yml
    done

  } >> ~/subspace/docker-compose.yml
fi

echo '    ]' >> ~/subspace/docker-compose.yml
