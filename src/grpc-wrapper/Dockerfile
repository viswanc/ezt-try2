FROM alpine:3.4

RUN apk -U add ca-certificates

EXPOSE 8080

COPY ./bin/grpc-wrapper /bin/grpc-wrapper

CMD ["grpc-wrapper"]
