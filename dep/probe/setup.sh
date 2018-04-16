#!/bin/sh

# Executes a kubectl command to apply/delete the configs from all the probes.

cd $(dirname "$0")

if [ "$#" -lt 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then

  echo "\nUsage:\n"
  echo "\n\t$ sh <script> <apply|delete> [replica count]\n"

else

  find ./config -depth 1 -not -path "*/\.*" -exec kubectl $1 -f {} \;

  if [ "$1" == "apply" ] && [ ! -z "$2" ]
  then
    find ./config -depth 1 -path "*/grpc-*" -exec kubectl scale --replicas=$2 -f {}/deployment.yaml \;
  fi
  exit

  kubectl $1 -f ../config/components/zipkin

  if [ "$(kubectl config current-context)" != "minikube" ] # Expose the ports through GCE firewall.
  then

    source ../utils/helpers.sh

    exposeNodePorts() { # Creates / deletes GCE firewall rules for the given service. #PLater: Move this to kube.sh; the issue is with sourcing helpers.sh as a relative path.

      serviceName=$1
      command=$2

      kubectl get services -o wide | filter ^$serviceName | coln 5 | awk 'gsub("/TCP,?", "\n"){}; gsub("[0-9]+:", "")' | filter .+ | while read port
      do
        gcloud compute firewall-rules $command $serviceName-$port --allow tcp:$port
      done
    }

    if [ "$1" == "apply" ]; then
      command="create"
    else
      command="delete"
    fi

    exposeNodePorts p-front-envoy $command

  fi

fi
