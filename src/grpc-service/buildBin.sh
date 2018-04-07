#!/bin/sh

cd $(dirname "$0")
env GOOS=linux GOARCH=amd64 go build -o bin/grpc-service server/main.go
