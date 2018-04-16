#!/bin/sh

# A util script to get a list of running pods of the given service.

cd $(dirname "$0")

# Data
service_name="$1"
service_dir="./config/$service_name"

# Imports
source ../utils/helpers.sh

# Helpers
reset_pod() {

  pod_id="$1"
  service_name="$2"

  echo "Resetting: $pod_id" >&2

  # #Note: For Envoy config changes to be reloaded, the configMap has to be updated.
  kubectl cp $service_dir/res/envoy-config.yaml $pod_id:/etc/probe/envoy-config.yaml -c envoy-sidecar # #Note: ConfigMaps aren't used as they couldn't be reloaded after changes.

  echo "Killing Envoy..." >&2

  while [ ! -z "$(kubectl exec -it $pod_id --tty=false -c envoy-sidecar -- ps -A | filter envoy)" ]
  do

    kubectl exec -it $pod_id --tty=false -c envoy-sidecar -- pkill -x envoy > /dev/null 2>&1
    sleep 1

  done

  echo "Starting Envoy..." >&2
  kubectl exec -it $pod_id --tty=false -c envoy-sidecar -- /usr/local/bin/envoy -c /etc/probe/envoy-config.yaml --service-cluster p-$service_name -l debug --log-path /etc/probe/envoy.log > /dev/null 2>&1 &

  echo "Waiting for Envoy..." >&2
  while [ -z "$(kubectl exec -it $pod_id --tty=false -c envoy-sidecar -- ps -A | filter envoy)" ]
  do
    sleep 1
  done

  echo "Restarting the service..." >&2
  kubectl cp ./res/bg.sh $pod_id:/etc/probe/bg.sh -c p-$service_name
  sh $service_dir/copyFiles.sh $pod_id $service_name

  echo "Stopping the service..."
  while [ "$(kubectl exec -it $pod_id --tty=false -c p-$service_name -- ps -A | filter $service_name)" ]
  do

    kubectl exec -it $pod_id --tty=false -c p-$service_name -- pkill -f $service_name > /dev/null 2>&1
    sleep 1
  done

  echo "Starting the service..."
  kubectl exec -it $pod_id --tty=false -c p-$service_name -- /bin/sh /etc/probe/bg.sh /etc/probe/service.log /bin/$service_name > /dev/null 2>&1 &  # #Note: The markers at the end are to discard the STD streams and to background the process.
}

# Main
n=1
for pod_id in `sh ../utils/getPods.sh p-$1` # #Note: while command breaks in case of an error in the loop.
do

  echo "Pod: $n"
  n="$(($n+1))"
  reset_pod $pod_id $service_name &
  wait

done
