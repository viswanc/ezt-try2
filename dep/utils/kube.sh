#!/bin/sh

# A set of helper functions, for other scripts.

# Imports
source helpers.sh

# Helpers
getLoadBalancerIP () { # Waits for and returns the external-IP of a load-balancer.

  EXT_IP="<pending>"
  while true
  do
    EXT_IP="$(kubectl get svc | grep ^$1\\b | awk '{printf $4}')"

    if [ "$EXT_IP" == "<pending>" ]
    then
      echo "Waiting for $1..." >&2
      sleep 1

    else
      break

    fi

  done

  echo $EXT_IP
}

getNodePortIP () { # Returns the external-IP of a node-port service.

  nodeName="$(kubectl get pods -o wide | filter ^$1- | coln 7)"
  echo "$(kubectl get nodes -o wide | filter ^$nodeName | coln 6)" # #Note: Word boundary couldn't looked for in awk (filter).
}

# Exports
getExtIPGCE() { # Gets the external IP of a service running on GCE.

  serviceName="$1"
  serviceInfo="$(kubectl get svc $serviceName | sed 1d)"

  if [ "$(echo $serviceInfo | coln 2)" == "NodePort" ]
  then

    EXT_IP="$(getNodePortIP $serviceName)"

  else

    EXT_IP="$(getLoadBalancerIP $serviceName)"

  fi

  echo $EXT_IP
}
