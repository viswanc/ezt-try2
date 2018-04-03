#!/bin/sh

# Info on the setup.

echo "Services available @:" $(kubectl get svc | grep front-envoy-lb | awk '{printf $4}')
echo "Zipkin available @:" $(kubectl get svc | grep zipkin-lb | awk '{printf $4}')
