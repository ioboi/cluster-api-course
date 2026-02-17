#!/usr/bin/env bash

kind delete cluster
cat << EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  ipFamily: ipv4
nodes:
- role: control-plane
  extraMounts:
    - hostPath: /var/run/docker.sock
      containerPath: /var/run/docker.sock
EOF

kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml

helm repo add capi-operator https://kubernetes-sigs.github.io/cluster-api-operator
helm repo update

kubectl -n cert-manager wait --for condition=available deployments --all --timeout=5m

helm upgrade --install capi-operator capi-operator/cluster-api-operator \
--create-namespace \
-n capi-operator-system \
--set infrastructure.docker.enabled=true \
--wait

kubectl -n capi-system wait --for condition=ready=true coreprovider cluster-api --timeout 5m
