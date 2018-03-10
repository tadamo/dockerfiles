#!/usr/bin/env bash
export envoy_listener_port=${LISTENER_PORT:-8000}
export envoy_admin_port=${ADMIN_PORT:-8001}
export envoy_target_ip_port=${TARGET_IP_PORT:-httpbin.org:80}

cat /etc/envoy-conf.json |
    jq ".listeners[0].address = \"tcp://0.0.0.0:$envoy_listener_port\" | .admin.address = \"tcp://0.0.0.0:$envoy_admin_port\" | .cluster_manager.clusters[0].hosts[0].url = \"tcp://$envoy_target_ip_port\"" > /etc/envoy-conf-run.json

cat /etc/envoy-conf-run.json
envoy -c /etc/envoy-conf-run.json
