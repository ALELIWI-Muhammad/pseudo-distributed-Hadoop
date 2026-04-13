# Pseudo-Distributed Hadoop

This project contains a pseudo-distributed Hadoop setup using Docker.

## Overview

In pseudo-distributed mode, Hadoop runs on a single node, but each daemon is executed in its own Java process. This is useful for learning and development because it imitates a distributed cluster while running entirely on one machine.

The container starts Hadoop services using the provided `entrypoint.sh`, and the project is launched with Docker Compose.

## Files

- `docker-compose.yml` - defines the Hadoop service and maps container ports to the host.
- `dockerfile` - builds the Hadoop image and copies configuration files.
- `entrypoint.sh` - formats HDFS if needed, configures SSH, and starts Hadoop services (`start-dfs.sh` and `start-yarn.sh`).
- `config-hadoop/` - contains Hadoop configuration files:
  - `core-site.xml`
  - `hdfs-site.xml`
  - `mapred-site.xml`
  - `yarn-site.xml`

## How to Run

From the `pseudo-distributed Hadoop` directory, run:

```bash
docker-compose up -d
```

This command:

- builds the Hadoop Docker image if necessary
- creates and starts the `hadoop-node-pseudo` container
- exposes the HDFS Web UI on `http://localhost:9870`
- exposes the YARN Web UI on `http://localhost:8088`

## Notes

- This setup is pseudo-distributed, not fully distributed. It runs all Hadoop daemons on one host.
- The HDFS Web UI should be accessible from the host machine at `http://localhost:9870` once the container is running.
- The container uses Docker volume `hadoop_data` to persist Hadoop filesystem data at `/hadoop/dfs`.

## Troubleshooting

If the UI is not accessible:

1. Ensure the container is running:
   ```bash
docker ps
```
2. Confirm port `9870` is mapped and open.
3. Check container logs:
   ```bash
docker logs hadoop-node-pseudo
```
