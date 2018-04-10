#!/bin/sh

# A script to reset the probes.

cd $(dirname "$0")

# Data
service_name="$1"
should_build="$2"
should_setup="$3"

# Imports
source ../utils/helpers.sh

# Helpers
reset_service() {

  if [ "$should_build" == "y" ]
  then
    echo "Building: $1"
    sh ../../src/$1/buildBin.sh
  fi

  sh ./resetProbe.sh $1
}

echo "\n\n\t----\tThe services are reset, even when some commands fail."
echo "\t----\tIf it's stuck, just rerun it.\n\n"

if [ "$should_setup" == "y" ]
then
  sh setup.sh delete
  sh setup.sh apply

  echo "Waiting for pods..."

  while [ ! -z "$(kubectl get pods | filter ^[^R]+$)" ]
  do
    sleep 1
  done
fi

if [ "$service_name" != "" ]
then

  if [ "$1" == "-h" ] || [ "$1" == "--help" ]
  then

    echo "Usage:\n\n\t$ <script> [service_name] [should_build=y|N] [should_setup=y|N]\n"

  else

    reset_service $service_name

  fi

else

  find ./config -type d -depth 1 -path "*grpc*" | while read directory; do

    reset_service $(basename "$directory")

  done

fi
