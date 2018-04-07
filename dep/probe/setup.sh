#!/bin/sh

# Executes a kubectl command to apply/delete the configs from all the probes.

cd $(dirname "$0")

if [ "$#" -lt 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then

  echo "\nUsage:\n"
  echo "\n\t$ sh <script> <apply|delete>"
  echo "\n"

else

  find ./config -depth 1 -not -path "*/\.*" -exec kubectl $1 -f {} \;

fi
