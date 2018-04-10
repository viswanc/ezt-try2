#!/bin/sh

# A script to demonstrate load-balancing between services with multiple pods. This along with the demo for multiplexed load balancing proves that envoy can handle load balancing between multiple of the same service.

# Setup
cd $(dirname "$0")

# Main
EXT_IP=$(minikube ip)
echo "\nExternal IP: $EXT_IP"

for i in $(seq 1 10)
do
  echo $i >&2
  curl $EXT_IP:30890/grpc/greet/10 2>/dev/null
done
