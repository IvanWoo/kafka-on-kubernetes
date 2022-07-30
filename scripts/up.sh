#!/bin/sh
# This file is autogenerated - DO NOT EDIT!

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${BASE_DIR}/.."
(
cd ${REPO_DIR}
kubectl create namespace kafka --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
kubectl apply -f kafka/values.yaml -n kafka
kubectl apply -f kafka/topics.yaml -n kafka
helm repo add kafka-ui https://provectus.github.io/kafka-ui
helm upgrade --install my-kafka-ui kafka-ui/kafka-ui --namespace kafka -f kafka-ui/values.yaml
)
