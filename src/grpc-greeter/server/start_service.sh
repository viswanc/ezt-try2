#!/usr/bin/env bash
/bin/grpc-greeter &
envoy -c /etc/envoy-config.yaml --service-cluster grpc-greeter
