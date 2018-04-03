#!/bin/sh

# A script for demo on accessing the grpc-service through a load-balancer.

# Setup
cd $(dirname "$0")

kubectl delete deployment lbt
kubectl run lbt --image=gcr.io/api-project-483163119575/grpc-service --port 8080 --command=true /usr/local/bin/start_service.sh 0.0.0.0:8080

kubectl delete service lbt
kubectl expose deployment lbt --type=LoadBalancer --port 80 --target-port 8080

export EXT_IP="<pending>"
while [ "$EXT_IP" == "<pending>" ]
do
  export EXT_IP=$(kubectl get svc | grep lbt | awk '{printf $4}')
  echo Waiting for external IP...
  sleep 1
done

# Main
echo \nExternal IP: $EXT_IP\n

# Test the gRPC service through the load balancer.
echo Calling the gRPC service...
go run src/grpc-service/client/main.go $EXT_IP:80
