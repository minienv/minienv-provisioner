#!/usr/bin/env bash
!#/bin/bash

# Start Docker
storage_driver=${MINIENV_STORAGE_DRIVER}
if [[ -z  ${storage_driver} ]]; then
    storage_driver="vfs"
fi
if [[ ! -z ${MINIENV_NODE_NAME_OVERRIDE} ]]; then
    registryMirror="http://$MINIENV_NODE_NAME_OVERRIDE:5000"
    /usr/local/bin/dockerd-entrypoint.sh --storage-driver=${storage_driver} --registry-mirror=${registryMirror} &
elif [[ ! -z ${NODE_NAME} ]]; then
    registryMirror="http://$NODE_NAME:5000"
    /usr/local/bin/dockerd-entrypoint.sh --storage-driver=${storage_driver} --registry-mirror=${registryMirror} &
else
    /usr/local/bin/dockerd-entrypoint.sh --storage-driver=${storage_driver} &
fi

# Wait for Docker to start
docker info > /dev/null 2>&1
code=$?
while [ ${code} -gt 0 ]; do
    echo "$(date) - Docker exited with code $code. Waiting for docker to start..."
    sleep 3
    docker info > /dev/null 2>&1
    code=$?
done

# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove images with no tag
docker rmi $(docker images | grep "<none>" | awk '{print $3}')

# Pull base minienv images
docker rmi $(docker images | grep "minienv" | awk '{print $3}')
docker pull minienv/minienv-log:${MINIENV_VERSION}
docker pull minienv/minienv-editor:${MINIENV_VERSION}
docker pull minienv/minienv-proxy:${MINIENV_VERSION}

# Pull configured docker images
if [[ ! -z ${MINIENV_PROVISION_IMAGES} ]]; then
    IFS=',' read -ra IMAGE <<< "$MINIENV_PROVISION_IMAGES"
    for i in "${IMAGE[@]}"; do
        docker pull ${i}
    done
fi

exit 0
