# Docker-in-Docker - Private Registry Login

## Purpose

Sort of like this: https://hub.docker.com/r/jpetazzo/dind/

I'm utilizing this from my CI/CD tool (Bamboo/Jenkins)...

But, I need to run a container that uses a private registry. Sure, I can mount a credentials file into the container, but I don't want the credentials file sitting around the CI/CD host.

## Synopsis

```
docker container run \
    --rm \
    -e DOCKER_REGISTRY="$DOCKER_REGISTRY" \
    -e DOCKER_REGISTRY_USER="$DOCKER_REGISTRY_USER" \
    -e DOCKER_REGISTRY_PASSWORD="$DOCKER_REGISTRY_PASSWORD" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    tadamo/dind-runner \
        docker container run \
            --rm \
            "$DOCKER_REGISTRY:this/image:latest" \
            sh -c "echo hello"
```
