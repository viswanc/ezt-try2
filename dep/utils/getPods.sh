#!/bin/sh

# A util script to get a list of running pods of the given service.

echo "\nGetting pods ...\n" >&2
count=$2
if [ "$count" == "" ]; then
  count=1
fi

while [ `kubectl get pods | grep ^$1- | awk '$3 == "Running" {printf "%s\n", $1}' | wc -l` -lt $count ]
do
echo 'Wating for pods...' >&2
done

kubectl get pods | grep ^$1- | awk '$3 == "Running" {printf "%s\n", $1}' | while read pod; do

  echo $pod

done
