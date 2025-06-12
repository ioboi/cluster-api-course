# Workload deployen

## 📁 kubeconfig abrufen

Cluster API erstellt für jedes Cluster eine eigene `kubeconfig`.
Damit greifst du direkt auf dein Workload-Cluster zu.

```bash
# Cluster-Namen prüfen
kubectl get clusters -A
```

Das Cluster aus der vorherigen Übung heisst `my-cluster`.
Speichere die kubeconfig lokal:

```bash
kubectl get secret my-cluster-kubeconfig \
  -o jsonpath='{.data.value}' | base64 -d > kubeconfig-workload
```

> Alternativ: `clusterctl get kubeconfig my-cluster > kubeconfig-workload`

Zugriff testen:

```bash
kubectl --kubeconfig=kubeconfig-workload get pods -A
```

## 🐝 Cilium installieren

Das Workload-Cluster braucht ein CNI.
Wir installieren [Cilium](https://cilium.io/) mit Helm:

```bash
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium \
  --kubeconfig=kubeconfig-workload \
  --namespace kube-system
```

## 🛜 nginx starten

Starte ein einfaches nginx-Deployment:

```bash
kubectl --kubeconfig=kubeconfig-workload \
  create deployment nginx --image=nginx
```

Pods prüfen:

```bash
kubectl --kubeconfig=kubeconfig-workload get pods
```
