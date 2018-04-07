#!/bin/sh

# A script to reset the probes.

cd $(dirname "$0")

# Data
service_name="$1"
should_build="$2"

# Helpers
reset_service() {

  if [ "$should_build" == "y" ]
  then
    echo "Building: $1"
    sh ../../src/$1/buildBin.sh
  fi

  sh ./resetProbe.sh $1
}

echo "\n\n\t\t----\tThe services are reset, even when some commands fail.\t---\n\n"

if [ "$service_name" != "" ]
then

  if [ "$1" == "-h" ] || [ "$1" == "--help" ]
  then

    echo "Usage:\n\n\t$ <script> [service_name] [should_build=y|n]\n"

  else

    reset_service $service_name

  fi

else

  find ./config -type d -depth 1 -not -path "*/\.*" | while read directory; do

    reset_service $(basename "$directory")

  done

fi
