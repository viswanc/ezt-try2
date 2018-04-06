#!/bin/sh

cd $(dirname "$0")

reset_pod() {

  pod_id="$1"
  service_name="$2"

  echo "Resetting: $pod_id..."
  kubectl exec -it $pod_id --tty=false -c envoy-sidecar -- /usr/local/bin/envoy -c /etc/envoy-config.yaml --service-cluster p-$service_name > /dev/null 2>&1 & # #Note: This is to discard the STD streams and to background the process.
  kubectl exec -it $pod_id --tty=false -c p-$service_name -- pkill -f $service_name || true
  kubectl exec -it $pod_id --tty=false -c p-$service_name -- /bin/$service_name > /dev/null 2>&1 &
}

# Reset the grpc-wrapper.
reset_pod `sh ../utils/getPods.sh p-grpc-wrapper` grpc-wrapper

# Reset the grpc-service.
sh ../utils/getPods.sh p-grpc-service | while read pod_id
do

  reset_pod $pod_id grpc-service & # #Note: The error thrown by the call breaks the while loop. Hence it has to be run in the background.
  wait

done
