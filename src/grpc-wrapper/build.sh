#!/bin/sh

cd $(dirname "$0")

sh ./buildBin.sh

docker build -t viswanathct/grpc-wrapper .

gcloud docker -- push viswanathct/grpc-wrapper
