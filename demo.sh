# A demo script.

# Setup
cd $(dirname "$0")

./dep/config.sh delete && ./dep/config.sh apply

export ZIPKIN_EXT_IP="<pending>"
while [ "$ZIPKIN_EXT_IP" == "<pending>" ]
do
  export ZIPKIN_EXT_IP=$(kubectl get svc | grep zipkin-lb | awk '{printf $4}')
  echo Waiting for zipkin...
  sleep 1
done

export EXT_IP="<pending>"
while [ "$EXT_IP" == "<pending>" ]
do
  export EXT_IP=$(kubectl get svc | grep front-envoy-lb | awk '{printf $4}')
  echo Waiting for external IP...
  sleep 1
done

# Main
echo "\nExternal IP: $EXT_IP"

echo "\nTesting the HTTP service"
curl $EXT_IP:80/trace/2
sleep 1

echo "\nEnsure that the gRPC wrapper is running."
curl $EXT_IP:8090/ping
sleep 1

echo "\nTest the gRPC service directly."
go run src/grpc-service/client/main.go $EXT_IP:8080

echo "\nTest gRPC routing through the wrapper."
curl -X POST $EXT_IP:8090/grpc/greet
sleep 1; echo "\n"
