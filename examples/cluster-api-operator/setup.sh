#!/usr/bin/env bash

set -euo pipefail

# ANCHOR: create-cluster
kind create cluster --config=config.yaml
# ANCHOR_END: create-cluster

# ANCHOR: cert-manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
# ANCHOR_END: cert-manager

# ANCHOR: wait-for-cert-manager
kubectl --namespace cert-manager \
	wait --for condition=available deployments --all --timeout=5m
# ANCHOR_END: wait-for-cert-manager

# ANCHOR: helm-repo-add
helm repo add capi-operator https://kubernetes-sigs.github.io/cluster-api-operator
helm repo update
# ANCHOR_END: helm-repo-add

# ANCHOR: helm-install
helm upgrade --install capi-operator capi-operator/cluster-api-operator \
	--create-namespace \
	--namespace capi-operator-system \
	--set infrastructure.docker.enabled=true \
	--wait
# ANCHOR_END: helm-install


# ANCHOR: wait-for-capd
kubectl --namespace docker-infrastructure-system \
  wait --for condition=ready=true infrastructureprovider/docker --timeout=5m
# ANCHOR_END: wait-for-capd

# ANCHOR:ns
kubectl get namespaces
# ANCHOR_END:ns
