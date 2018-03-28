env GOOS=linux GOARCH=amd64 go build -o bin/grpc-greeter server/main.go

docker build -t viswanathct/grpc-greeter .
