#!/bin/env bash

set -x
MONGODB_VERSION="3.6"
NODE_EXPORTER_VERSION="0.18.1"

sleep 30
sudo yum -y update 
sudo yum -y install git glibc-static golang tuned

# Define tuned profile
sudo tuned-adm profile throughput-performance
sudo systemctl enable tuned

# Set timezone
sudo ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Installing MongoDB
sudo su - -c 'sudo mv /tmp/mongodb-org.repo /etc/yum.repos.d/mongodb-org.repo'
sudo yum install -y mongodb-org-${MONGODB_VERSION}*
sudo /sbin/chkconfig mongod off
sudo mkdir /mongodb
sudo rm -f /etc/mongod.conf
sudo ln -s /mongodb/mongod.conf  /etc/mongod.conf
sudo chown mongod.mongod -R /mongodb
sudo su - -c "echo 'LABEL=/mongodb /mongodb xfs defaults 0 0' >> /etc/fstab"
sudo su - -c "echo 'LABEL=SWAP none swap sw 0 0' >> /etc/fstab"

# Download node_exporter
sudo wget -qO- "https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz" | tar -xvz
sudo chown root.root node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter
sudo mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/bin/node_exporter

# Configuring Prometheus exporters
sudo mv /tmp/node_exporter.service /etc/systemd/system/
sudo systemctl enable node_exporter
sudo su - -c 'export GOROOT=/usr/lib/golang && export GOPATH=$GOROOT && export PATH=$PATH:$GOPATH/bin && curl https://glide.sh/get | sh && export GOPATH=/usr/mongodb_exporter && git clone https://github.com/dcu/mongodb_exporter.git $GOPATH/src/github.com/dcu/mongodb_exporter && cd $GOPATH/src/github.com/dcu/mongodb_exporter && make build'
sudo mv /usr/mongodb_exporter/src/github.com/dcu/mongodb_exporter/mongodb_exporter /usr/bin/mongodb_exporter
sudo mv /tmp/mongodb_exporter.service /etc/systemd/system/
sudo systemctl enable mongodb_exporter
