# Lokales Setup

## ⚙️ Voraussetzungen

Installiere folgende Tools:

- [Docker](https://www.docker.com/get-started/) oder [Podman](https://podman.io/get-started)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) oder [minikube](https://minikube.sigs.k8s.io/docs/start)
- [Helm](https://helm.sh/docs/intro/install/)
- [clusterctl](https://cluster-api.sigs.k8s.io/user/quick-start#install-clusterctl)

## 📦 Cluster starten

### Mit `kind`:

```bash
cat > kind-cluster-with-extramounts.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  ipFamily: dual
nodes:
- role: control-plane
  extraMounts:
    - hostPath: /var/run/docker.sock
      containerPath: /var/run/docker.sock
EOF
```

```bash
kind create cluster --name capi-mgmt \
   --config kind-cluster-with-extramounts.yaml
```

Löschen mit:

```bash
kind delete cluster --name capi-mgmt
```

**Alternativ: `minikube`**

```bash
minikube start
```

Achtung: `minikube` nutzt eigene Treiber (Docker, Hyperkit, etc.)

## 🚀 Cluster API installieren

Starte die Initialisierung:

```bash
clusterctl init
```

Das installiert:

- CAPI-Komponenten (Core, Bootstrap, Control Plane)
- [cert-manager](https://cert-manager.io/)
