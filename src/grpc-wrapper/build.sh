cd $(dirname "$0")

env GOOS=linux GOARCH=amd64 go build -o bin/grpc-wrapper src/main.go

docker build -t gcr.io/api-project-483163119575/grpc-wrapper .

gcloud docker -- push gcr.io/api-project-483163119575/grpc-wrapper
