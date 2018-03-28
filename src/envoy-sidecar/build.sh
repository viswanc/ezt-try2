cd $(dirname "$0")

docker build -t gcr.io/api-project-483163119575/envoy-sidecar .

gcloud docker -- push gcr.io/api-project-483163119575/envoy-sidecar
