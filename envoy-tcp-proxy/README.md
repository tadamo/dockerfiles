# Purpose

Run a tcp proxy via container. Can create a tunnel to a remote service.

Uses envoy to create a TCP proxy. Updates envoy configuration at runtime with ENV variables.

# Example

```
$ docker run \
    --name envoy-tcp-proxy \
    -e LISTENER_PORT=1521 \
    -p 1521:1521 \
    -e ADMIN_PORT=8001 \
    -p 8001:8001 \
    -e TARGET_IP_PORT=some-oracle-db.org:1521 \
    tadamo/envoy-tcp-proxy
```
