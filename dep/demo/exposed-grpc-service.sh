#!/bin/sh

# A demo script on accessing the grpc-service through a load-balancer.

# Setup
cd $(dirname "$0")

# Data
demoName=exp-grpc-service

kubectl delete deployment $demoName
kubectl run $demoName --image=viswanathct/grpc-service --port 8080 --command=true /usr/local/bin/start_service.sh 0.0.0.0:8080

kubectl delete service $demoName
kubectl expose deployment $demoName --type=LoadBalancer --port 80 --target-port 8080

# Main
EXT_IP=$(sh ../utils/getExtIP.sh $demoName)

# Test the gRPC service through the load balancer.
echo "Calling the gRPC service..."
go run ../../src/grpc-service/client/main.go $EXT_IP:80
