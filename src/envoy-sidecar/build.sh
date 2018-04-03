cd $(dirname "$0")

docker build -t viswanathct/envoy-sidecar .

gcloud docker -- push viswanathct/envoy-sidecar
