#!/bin/sh

# A demo on load balancing HTTP2 (live) connections through Envoy.

# Data
demoName=h2klb

# Setup
cd $(dirname "$0")

# Part 1
########

if [ "$1" == "reset" ]
then

  kubectl delete deployment $demoName
  kubectl delete service $demoName

  kubectl run $demoName --image=viswanathct/grpc-service --port 8080 -r 2 --command=true /usr/local/bin/start_service.sh 0.0.0.0:8080
  kubectl expose deployment $demoName --type=LoadBalancer --port 80 --target-port 8080

fi

EXT_IP=$(sh ../utils/getExtIP.sh $demoName)

sh ../utils/getPods.sh $demoName | while read pod; do

  echo "kubectl logs $pod -f"

done

echo "\nRun the above commands in to separate terminals to watch the logs of the pods... and press any key to continue...\n"

read dummy

echo "Testing multiplexing without Envoy... on $EXT_IP (only one pod will be hit)"
go run ../../src/grpc-service/client/main.go $EXT_IP:80 m

echo "\nDone. Press any key to continue...\n"

# Part 2
########

serviceName=grpc-service

if [ "$1" == "reset" ]; then sh ../utils/resetService.sh $serviceName; fi

sh ../utils/getPods.sh $serviceName | while read pod; do

  echo "kubectl logs $pod -c grpc-service -f"

done

echo "\nRun the above commands in to separate terminals to watch the logs of the pods... and press any key to continue...\n"

read dummy

EXT_IP=$(sh ../utils/getExtIP.sh front-envoy-lb)
echo "Testing multiplexing with Envoy... on $EXT_IP (both the pods will be hit)"
go run ../../src/grpc-service/client/main.go $EXT_IP:8080 m
