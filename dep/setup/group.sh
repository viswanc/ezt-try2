#!/bin/sh

# Executes a kubectl command using all the configs from a specific subdir.

cd $(dirname "$0")

if [ "$#" -lt 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then

  echo "\nUsage:\n"
  echo "\n\t$ sh group.sh <apply|delete> <group>\n"

  echo "\nGroups:"

  find ../config -type d -depth 1 -not -path "*/\.*" | while read line; do

    echo "\t"$(basename "$line")

  done

  echo "\n"

else

  find ../config/$2 -type d -depth 1 -not -path "*/\.*" -exec kubectl $1 -f {} \;

fi
