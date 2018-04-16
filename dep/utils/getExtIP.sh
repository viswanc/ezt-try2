#!/bin/sh

# A util script to wait for an external IP.

cd $(dirname "$0")

if [ "$(kubectl config current-context)" == "minikube" ]
then

  EXT_IP=`minikube ip`

else

  source kube.sh # #Note: The script has to be in the same dir as the parent, for indirect imports to work.

  EXT_IP="$(getExtIPGCE $1)"

fi

echo $EXT_IP
