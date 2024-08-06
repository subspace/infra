#!/bin/sh
source $HOME/.bash_profile
cat > $HOME/squid/docker-compose.yml << EOF
version: "3.8"

services:
  db_replica:
    image: postgres:16
    shm_size: 1gb
    volumes:
      - db_data_replica:/var/lib/postgresql/data
      - ./postgresql_replica.conf:/etc/postgresql/postgresql.conf:ro
    environment:
      POSTGRES_DB: squid-archive
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "5432:5432"
    command: >
      bash -c "
      until pg_isready -h ${PRIMARY_HOST} -p 5432 -U ${POSTGRES_USER}; do sleep 1; done;
      pg_basebackup -h ${PRIMARY_HOST} -D /var/lib/postgresql/data -U ${POSTGRES_USER} -P -v -R -X stream -S replica_slot;
      echo 'primary_conninfo = ''host=${PRIMARY_HOST} port=5432 user=${POSTGRES_USER} password=${POSTGRES_PASSWORD}''' >> /var/lib/postgresql/data/postgresql.auto.conf;
      touch /var/lib/postgresql/data/standby.signal;
      postgres -c config_file=/etc/postgresql/postgresql.conf"

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
      NRIA_DISPLAY_NAME: "squid-\${NETWORK_NAME}-db-replica"
    restart: unless-stopped

volumes:
  db_data_replica:

EOF
