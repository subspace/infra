#!/bin/bash
EXTERNAL_IP=`curl -s ifconfig.me`
source $HOME/.bash_profile
cat > $HOME/archive/docker-compose.yml << EOF
version: "3.7"

volumes:
  archival_node_data: {}
  db_data: {}

services:
  db:
    image: postgres:16
    restart: always
    volumes:
      - db_data:/var/lib/postgresql/data
      - type: bind
        source: $HOME/archive/postgresql/postgresql.conf
        target: /etc/postgresql/postgresql.conf
        read_only: true
    environment:
      POSTGRES_USER: \${POSTGRES_USER}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD}
      POSTGRES_DB: \${POSTGRES_DB}
    logging:
      driver: loki
      options:
        loki-url: "https://logging.subspace.network/loki/api/v1/push"

  ingest:
    depends_on:
      - db
    restart: on-failure
    image: ghcr.io/autonomys/substrate-ingest:\${DOCKER_TAG}
    logging:
      driver: loki
      options:
        loki-url: "https://logging.subspace.network/loki/api/v1/push"
    command: [
      "-e", "ws://node:9944",
      "-c", "10",
       "--prom-port", "9090",
       "--out", "postgres://postgres:postgres@db:\${POSTGRES_PORT}/\${POSTGRES_DB}"
    ]
    environment:
      NODE_TLS_REJECT_UNAUTHORIZED: 0

  gateway:
    depends_on:
      - db
    image: subsquid/substrate-gateway:firesquid
    environment:
      RUST_LOG: "substrate_gateway=info,actix_server=info"
    command: [
       "--database-url", "postgres://postgres:postgres@db:\${POSTGRES_PORT}/\${POSTGRES_DB}",
       "--database-max-connections", "6", # max number of concurrent database connections
       # these parameters have to be adjusted depending on machine resources to avoid OOM
       "--scan-start-value", "20", # works as batch size but for a whole archive, default is 100
       "--scan-max-value", "20000" # upper limit for the amount of blocks, default is 100000
    ]
    ports:
      - "8888:8000"
    logging:
      driver: loki
      options:
        loki-url: "https://logging.subspace.network/loki/api/v1/push"

  # Explorer service is optional.
  # It provides rich GraphQL API for querying archived data.
  # Many developers find it very useful for exploration and debugging.
  explorer:
    image: subsquid/substrate-explorer:firesquid
    environment:
      DB_TYPE: \${DB_TYPE}
      DB_HOST: \${DB_HOST}
      DB_PORT: \${DB_PORT}
      DB_NAME: \${DB_NAME}
      DB_USER: \${DB_USER}
      DB_PASS: \${DB_PASS}
    ports:
      - "4444:3000"
    logging:
      driver: loki
      options:
        loki-url: "https://logging.subspace.network/loki/api/v1/push"

  node:
    image: ghcr.io/autonomys/node:\${NODE_TAG}
    volumes:
      - archival_node_data:/var/subspace:rw
    restart: unless-stopped
    command: [
      "run",
      "--chain", "\${NETWORK_NAME}",
      "--base-path", "/var/subspace",
      "--state-pruning", "archive",
      "--blocks-pruning", "archive",
      "--listen-on", "/ip4/0.0.0.0/tcp/30333",
      "--dsn-external-address", "/ip4/$EXTERNAL_IP/udp/30433/quic-v1",
      "--rpc-cors", "all",
      "--rpc-listen-on", "0.0.0.0:9944",
      "--rpc-methods", "safe",
      "--name", "\${NODE_NAME}"
    ]
    healthcheck:
      timeout: 5s
      interval: 30s
      retries: 5
    logging:
      driver: loki
      options:
        loki-url: "https://logging.subspace.network/loki/api/v1/push"

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
      NRIA_DISPLAY_NAME: "archive-squid-\${NETWORK_NAME}"
    restart: unless-stopped

  pg-health-check:
    image: ghcr.io/autonomys/health-check:latest
    environment:
      POSTGRES_HOST: \${POSTGRES_HOST}
      POSTGRES_PORT: \${POSTGRES_PORT}
      PORT: \${HEALTH_CHECK_PORT}
      SECRET: \${MY_SECRET}
    command: "postgres"
    ports:
      - 8080:8080

  prom-health-check:
    image: ghcr.io/autonomys/health-check:latest
    environment:
      PROMETHEUS_HOST: \${INGEST_HEALTH_HOST}
      PORT: \${INGEST_HEALTH_PORT}
      SECRET: \${MY_SECRET}
    command: "prometheus"
    ports:
      - 7070:7070
EOF
