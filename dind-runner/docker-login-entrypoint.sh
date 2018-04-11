#!/usr/bin/env sh
set -e

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "DOCKER_REGISTRY is not set"
    exit 1
elif [ -z "$DOCKER_REGISTRY_USER" ]; then
    echo "DOCKER_REGISTRY_USER is not set"
    exit 1
elif [ -z "$DOCKER_REGISTRY_PASSWORD" ]; then
    echo "DOCKER_REGISTRY_PASSWORD is not set"
    exit 1
fi

echo "Logging into $DOCKER_REGISTRY as $DOCKER_REGISTRY_USER..."
echo "$DOCKER_REGISTRY_PASSWORD" | \
    docker login \
    -u "$DOCKER_REGISTRY_USER" \
    --password-stdin \
    "$DOCKER_REGISTRY"

exec docker-entrypoint.sh "$@"
