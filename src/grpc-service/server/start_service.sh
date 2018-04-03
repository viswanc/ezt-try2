#!/usr/bin/env bash

export GODEBUG=http2debug=2 # Enable http2 debugging.
/bin/grpc-service $1
