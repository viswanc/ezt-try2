#!/bin/sh

# Resets the given service.

kubectl delete -f ../config/services/$1 && kubectl apply -f ../config/services/$1
