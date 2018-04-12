#!/bin/sh

# A util script to wait for an external IP.

if [ "$(kubectl config current-context)" == "minikube" ]
then

  EXT_IP=`minikube ip`

else

  EXT_IP="<pending>"
  while [ "$EXT_IP" == "<pending>" ]
  do
    EXT_IP=$(kubectl get svc | grep ^$1$ | awk '{printf $4}')
    echo "Waiting for $1..." >&2
    sleep 1
  done

fi

echo $EXT_IP
