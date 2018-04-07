#!/bin/sh

# A util script to get a list of running pods of the given service.

cd $(dirname "$0")

# Data
service_name="$1"

# Helpers
reset_pod() {

  pod_id="$1"
  service_name="$2"

  echo "Resetting: $pod_id..."
  kubectl exec -it $pod_id --tty=false -c envoy-sidecar -- /usr/local/bin/envoy -c /etc/envoy-config.yaml --service-cluster p-$service_name > /dev/null 2>&1 & # #Note: This is to discard the STD streams and to background the process.

  kubectl cp ./res/bg.sh $pod_id:/probe/bg.sh -c p-$service_name
  kubectl exec -it $pod_id --tty=false -c p-$service_name -- pkill -f $service_name || true
  kubectl exec -it $pod_id --tty=false -c p-$service_name -- /bin/sh /probe/bg.sh /probe/service.log /bin/$service_name &
}

# Main
kubectl apply -f ./config/$service_name

for pod_id in `sh ../utils/getPods.sh p-$1` # #Note: while command breaks in case of an error in the loop.
do

  sh ./config/$service_name/copyFiles.sh $pod_id $service_name
  reset_pod $pod_id $service_name &
  wait

done
