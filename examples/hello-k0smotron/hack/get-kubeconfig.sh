#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
mkdir -p .kube

kubectl wait --for=condition=available cluster/k0s-example --timeout 5m
kubectl get secret/k0s-example-kubeconfig -o template='{{.data.value|base64decode}}' > .kube/config-k0s-example
