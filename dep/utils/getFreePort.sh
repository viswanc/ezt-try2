#!/bin/sh

# A util script to get a free port.
# #From: https://stackoverflow.com/questions/28989069/how-to-find-a-free-tcp-port

#
BASE_PORT=${1:-8000}
INCREMENT=${2:-1}

port=$BASE_PORT
isfree=$(netstat -taln | grep $port)

while [[ -n "$isfree" ]]; do
  port=$[port+INCREMENT]
  isfree=$(netstat -taln | grep $port)
done

echo "$port"
