FROM envoyproxy/envoy-alpine:latest

RUN apk -U add ca-certificates
RUN apk update && apk add bash

COPY ./bin/grpc-greeter /bin/grpc-greeter
ADD ./server/start_service.sh /usr/local/bin/start_service.sh
RUN chmod u+x /usr/local/bin/start_service.sh

ENTRYPOINT pwd
