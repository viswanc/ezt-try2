#!/bin/sh

# A script to expose the services.

cd $(dirname "$0")

kubectl apply -f ../config/gateways

sh ../utils/getExtIP.sh zipkin-lb
sh ../utils/getExtIP.sh front-envoy-lb
