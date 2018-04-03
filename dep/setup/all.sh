#!/bin/sh

# Executes a kubectl command to apply/delete the configs from all the subdirs.

cd $(dirname "$0")

if [ "$#" -lt 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then

  echo "\nUsage:\n"
  echo "\n\t$ sh all.sh <apply|delete>"
  echo "\n"

else

  find ../config -type d -depth 2 -not -path "*/\.*" -exec kubectl $1 -f {} \;

  if [ "$1" == "apply" ]
  then

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

  fi

fi
