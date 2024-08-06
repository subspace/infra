# Docker.

## Subspace.

Subspace images are available in:

- Node: https://github.com/autonomys/subspace/pkgs/container/node
- Farmer: https://github.com/autonomys/subspace/pkgs/container/farmer
- Relayer: https://github.com/autonomys/subspace-relayer/pkgs/container/relayer

## Datadog agent.

To start Datadog agent with auto-discovery mode. Datadog will automatically send logs and metrics.

**Replace DD_API_KEY.**

```

    docker run -d --name datadog-agent \
    -e DD_API_KEY=9999999999999999999999999999999 \
    -e DD_LOGS_ENABLED=true \
    -e DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true \
    -e DD_CONTAINER_EXCLUDE_LOGS="name:datadog-agent" \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /proc/:/host/proc/:ro \
    -v /opt/datadog-agent/run:/opt/datadog-agent/run:rw \
    -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
    datadog/agent:latest

```

Check log status, https://app.datadoghq.com/logs
