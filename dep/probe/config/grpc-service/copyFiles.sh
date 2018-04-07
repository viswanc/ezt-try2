#!/bin/sh

# #Note: This file shouldn't be executed directly.

cd $(dirname "$0")

# Data
pod_id="$1"
service_name="$2"

# Main
kubectl cp ../../../../src/$service_name/bin/$service_name $pod_id:/bin/$service_name -c p-$service_name
