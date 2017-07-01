#!/bin/sh

# Start Docker
storage_driver=${MINIENV_STORAGE_DRIVER}
if [[ -z  ${storage_driver} ]]; then
    storage_driver="vfs"
fi
if [[ ! -z ${NODE_NAME} ]]; then
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

# Pull docker images
# TODO:

exit 0