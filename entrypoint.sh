#!/bin/bash

# Format HDFS (only first time)
if [ ! -d "/hadoop/dfs/name" ]; then
  echo "Formatting HDFS..."
  hdfs namenode -format
fi

# Start SSH
service ssh start

# Start HDFS
start-dfs.sh

# Start YARN
start-yarn.sh

#Vérifier avec jps
jps
# Keep container alive
tail -f /dev/null