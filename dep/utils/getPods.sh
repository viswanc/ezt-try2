#!/bin/sh

# A util script to get a list of running pods of the given service.

# Usage:
# $ <script> <serviceName> [shouldRun y|n] [expected pods]

serviceName="$1"
shouldRun="${2:-y}"
podCount="${3:-1}"

if [ "$shouldRun" == "y" ]
then
  operator="=="
else
  operator="!="
fi

awkCommand="awk '\$3 $operator \"Running\" && \$3 != \"Terminating\" {print \$1}'"

echo 'Wating for pods...' >&2

while true
do
  pods=`kubectl get pods | grep ^$serviceName- | eval $awkCommand`

  if [ ! -z "$pods" ] && [ `echo "$pods" | wc -l` -ge $podCount ]
  then
    echo "$pods"
    break
  fi

  sleep 1

done
