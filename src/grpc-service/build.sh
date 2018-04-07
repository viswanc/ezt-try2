cd $(dirname "$0")

sh ./buildBin.sh

docker build -t viswanathct/grpc-service .

gcloud docker -- push viswanathct/grpc-service
