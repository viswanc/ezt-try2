#!/bin/sh

# A script for demo on request-tracing.

# Setup
cd $(dirname "$0")

# Main
export EXT_IP=$(kubectl get svc | grep front-envoy-lb | awk '{printf $4}')
echo "\nExternal IP: $EXT_IP"

echo "\nTesting the HTTP service"
curl $EXT_IP:80/trace/2
sleep 1

echo "\nTest the gRPC service directly."
pwd
go run ../../src/grpc-service/client/main.go $EXT_IP:8080

echo "\nTest gRPC routing through the wrapper."
echo "\n\tEnsuring that the gRPC wrapper is running..."
curl $EXT_IP:8090/ping
echo "\n"
sleep 1

curl -X POST $EXT_IP:8090/grpc/greet
sleep 1; echo "\n"
