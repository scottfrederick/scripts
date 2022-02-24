#!/bin/bash

if ! command -v jq &> /dev/null
then
    echo "jq is required"
    exit 1
fi

if ! command -v sponge &> /dev/null
then
    echo "sponge is required"
    exit 1
fi


if [ -d /home/docker ]; then
  echo "/home/docker exists"
else 
  sudo mkdir /home/docker
  sudo chown root:root /home/docker
fi

docker system prune
sudo systemctl stop docker.service docker.socket

sudo rsync -avzP /var/lib/docker/ /home/docker

if [ -f /etc/docker/daemon.json ]; then
  jq '."data-root"="/home/docker"' /etc/docker/daemon.json | sudo sponge /etc/docker/daemon.json
else
  jq -n '."data-root"="/home/docker"' | sudo tee /etc/docker/daemon.json 
fi

sudo systemctl start docker.service docker.socket
