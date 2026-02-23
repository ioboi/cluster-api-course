#!/usr/bin/env bash

cat << EOF | kind create cluster --config=-
# ANCHOR: KindConfig
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  ipFamily: ipv4
nodes:
- role: control-plane
  extraMounts:
    - hostPath: /var/run/docker.sock
      containerPath: /var/run/docker.sock
  extraPortMappings:
  - containerPort: 30443 # (1)
    hostPort: 30443
  - containerPort: 30132 # (2)
    hostPort: 30132
# ANCHOR_END: KindConfig
EOF

kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
kubectl --namespace cert-manager wait --for condition=available deployments --all --timeout=5m

kubectl apply -f https://github.com/kubernetes-sigs/cluster-api-operator/releases/download/v0.25.0/operator-components.yaml
kubectl --namespace capi-operator-system wait --for condition=available deployments --all --timeout=5m

sleep 1 # Give the capi-operator some time to catch up. Somehow the condition is set earlier than the webhook actually is available.

# Install providers
kubectl apply -f providers/

# Wait for all providers to get ready
providers=(coreproviders infrastructureproviders controlplaneproviders bootstrapproviders)
for provider in "${providers[@]}"; do
  kubectl wait --for condition=ready "$provider" --all --all-namespaces --timeout 5m
done
