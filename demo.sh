# A demo script.

# Setup
cd $(dirname "$0")
export EXT_IP=$(kubectl get svc | grep front-envoy-lb | awk '{printf $4}') && echo $EXT_IP

# Ensure that HTTP calls are made.
curl $EXT_IP:80/trace/2
sleep 1; echo "\n"

# Ensure that the gRPC wrapper is running.
curl $EXT_IP:8090/ping
sleep 1; echo "\n"

# Test gRPC routing through the wrapper. #Note: This fails.
curl -X POST $EXT_IP:8090/grpc/greet
sleep 1; echo "\n"

# Test the gRPC service directly. #Note: This fails.
go run src/grpc-service/client/main.go $EXT_IP:8080
