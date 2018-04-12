#!/bin/sh

# A util script to get a list of running pods of the given service.

count=${2:-1}

echo 'Wating for pods...' >&2
while [ `kubectl get pods | grep ^$1- | awk '$3 == "Running" {printf "%s\n", $1}' | wc -l` -lt $count ]
do
  sleep 1
done

kubectl get pods | grep ^$1- | awk '$3 == "Running" {printf "%s\n", $1}' | while read pod; do

  echo $pod

done
