#!/bin/sh

# Deploy the structure to the cloud, afresh.

cd $(dirname "$0")

sh all.sh delete
sh all.sh apply

echo "\n-----------------\n"
sh info.sh

echo "\n-----------------"
