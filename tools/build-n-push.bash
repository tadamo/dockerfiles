#!/usr/bin/env bash
set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes
set -o xtrace   # Print command traces before executing command

docker buildx build --no-cache --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 -t tadamo/tools:latest .
