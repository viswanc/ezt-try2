#!/bin/sh

# A script to expose the services.

cd $(dirname "$0")
gatewayDir="../config/gateways"

kubectl apply -f $gatewayDir

while [ `kubectl get services | awk '$2=="LoadBalancer" && match($4, /^[^0-9].*$/) {printf " \n"}' | wc -l` -gt 0 ]
do
  echo "Waiting for external IPs..."
  sleep 1
done

kubectl get services | awk '$2=="LoadBalancer" {printf "%s -> %s\n", $4, $1}'
