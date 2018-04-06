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

    sh ./expose.sh

  else

    kubectl $1 -f ../config/gateways

  fi

fi
