#!/bin/bash -eu

#To export the variable succesfully execute this scrip with . ./exp_docker_groupid.sh

export DOCKER_GROUP_ID=$(getent group docker | awk -F: '{printf "%d",$3}')

echo "DOCKER_GROUP_ID=$DOCKER_GROUP_ID"

export DOCKER_HOST=unix:///var/run/docker.sock

echo "DOCKER_HOST=$DOCKER_HOST"

printf "DOCKER_HOST=$DOCKER_HOST\nDOCKER_GROUP_ID=$DOCKER_GROUP_ID" > docker.env
