#!/bin/bash

# Format HDFS (only first time)
if [ ! -d "/hadoop/dfs/name" ]; then
  echo "Formatting HDFS..."
  hdfs namenode -format
fi

# Configure SSH for root passwordless login before starting services
mkdir -p /root/.ssh
chmod 700 /root/.ssh
if [ ! -f /root/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
fi
PUBKEY=$(cat /root/.ssh/id_rsa.pub)
if ! grep -qxF "$PUBKEY" /root/.ssh/authorized_keys 2>/dev/null; then
  echo "$PUBKEY" >> /root/.ssh/authorized_keys
fi
chmod 600 /root/.ssh/authorized_keys

cat > /root/.ssh/config <<'EOF'
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  LogLevel ERROR
EOF
chmod 600 /root/.ssh/config

if grep -qE '^#?PermitRootLogin' /etc/ssh/sshd_config; then
  sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
else
  echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
fi
if grep -qE '^#?PasswordAuthentication' /etc/ssh/sshd_config; then
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
else
  echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
fi

# Start SSH
service ssh start

# Ensure local hostname resolves inside the container
HOSTNAME=$(hostname)
if ! grep -qE "^127\\.0\\.0\\.1\\s+localhost" /etc/hosts; then
  echo "127.0.0.1 localhost" >> /etc/hosts
fi
if ! grep -q "$HOSTNAME" /etc/hosts; then
  echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
fi

ssh-keyscan -H localhost "$HOSTNAME" >> /root/.ssh/known_hosts 2>/dev/null || true
chmod 644 /root/.ssh/known_hosts

# Allow Hadoop scripts to run as root in this container
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root
export HADOOP_SSH_OPTS='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR'

# Start HDFS
start-dfs.sh

# Start YARN
start-yarn.sh

#Vérifier avec jps
jps
# Keep container alive
tail -f /dev/null