# Übung: Cluster API Pivot

## 🎯 Was ist ein Pivot?

Pivot bezeichnet den Prozess, bei dem Provider-Komponenten und Cluster API-Ressourcen von einem Management-Cluster zu einem anderen Management-Cluster verschoben werden. Du startest mit einem temporären Bootstrap-Cluster und verschiebst alle Cluster API-Objekte zu einem dauerhafteren Ziel-Cluster.

**Warum Pivot?**

- **Skalierbarkeit**: Das zentrale Management kann wachsen
- **Stabilität**: Dauerhafte Cluster ersetzen temporäre
- **Produktion**: Von Entwicklung zu Produktions-Management

---

## 🚀 Schritt 1: Bootstrap-Cluster erstellen

Erstelle eine Kind-Konfiguration:

```bash
cat > kind-cluster-with-extramounts.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: bootstrap
networking:
  ipFamily: dual
nodes:
- role: control-plane
  extraMounts:
    - hostPath: /var/run/docker.sock
      containerPath: /var/run/docker.sock
EOF
```

Starte den Bootstrap-Cluster:

```bash
kind create cluster --config=kind-cluster-with-extramounts.yaml
```

**Was passiert:** Kind erzeugt einen temporären Kubernetes-Cluster namens "bootstrap". Dieser Cluster dient als Ausgangspunkt – er wird später wieder gelöscht.

---

## 🔧 Schritt 2: Cluster API initialisieren

Installiere Cluster API im Bootstrap-Cluster:

```bash
clusterctl init --infrastructure docker --addon helm
```

**Was passiert:** clusterctl installiert alle Cluster API-Controller (Core, Bootstrap, Control Plane) sowie den Docker-Provider (CAPD) in deinen Bootstrap-Cluster.

---

## 🎯 Schritt 3: Pivot-Cluster erzeugen

Erstelle das Manifest für dein Pivot-Cluster:

```yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: pivot
  namespace: default
spec:
  clusterNetwork:
    services:
      cidrBlocks: ["10.96.0.0/12"]
    pods:
      cidrBlocks: ["192.168.0.0/16"]
    serviceDomain: cluster.local
  controlPlaneRef:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta1
    kind: KubeadmControlPlane
    name: controlplane-pivot
    namespace: default
  infrastructureRef:
    apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
    kind: DockerCluster
    name: pivot
    namespace: default
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: DockerCluster
metadata:
  name: pivot
  namespace: default
---
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
  name: controlplane-pivot
  namespace: default
spec:
  replicas: 1
  version: v1.33.0
  machineTemplate:
    infrastructureRef:
      apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
      kind: DockerMachineTemplate
      name: controlplane
      namespace: default
  kubeadmConfigSpec:
    clusterConfiguration:
      apiServer:
        certSANs:
          - localhost
          - 127.0.0.1
          - 0.0.0.0
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: DockerMachineTemplate
metadata:
  name: controlplane
  namespace: default
spec:
  template:
    spec:
      extraMounts:
        - hostPath: /var/run/docker.sock
          containerPath: /var/run/docker.sock
---
apiVersion: cluster.x-k8s.io/v1beta1
kind: MachineDeployment
metadata:
  name: worker-md-0
  namespace: default
spec:
  clusterName: pivot
  replicas: 1
  selector:
    matchLabels:
      cluster.x-k8s.io/cluster-name: pivot
  template:
    spec:
      version: v1.33.0
      clusterName: pivot
      bootstrap:
        configRef:
          apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
          kind: KubeadmConfigTemplate
          name: worker
          namespace: default
      infrastructureRef:
        apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
        kind: DockerMachineTemplate
        name: worker
        namespace: default
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: DockerMachineTemplate
metadata:
  name: worker
  namespace: default
spec:
  template:
    spec:
      extraMounts:
        - hostPath: /var/run/docker.sock
          containerPath: /var/run/docker.sock
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
metadata:
  name: worker
  namespace: default
spec:
  template:
    spec: {}
```

Wende das Manifest an:

```bash
kubectl apply -f pivot-cluster.yaml
```

**Was passiert:** Der Bootstrap-Cluster erstellt ein neues Kubernetes-Cluster namens "pivot". Dieses wird später dein dauerhaftes Management-Cluster.

---

## 📡 Schritt 4: kubeconfig für Pivot-Cluster abrufen

Hole die kubeconfig für das neue Cluster:

```bash
clusterctl get kubeconfig pivot > pivot.kubeconfig
```

**Was passiert:** clusterctl extrahiert die Zugangsdaten für dein Pivot-Cluster und speichert sie lokal. Du kannst jetzt direkt mit dem Pivot-Cluster sprechen.

---

## 🌐 Schritt 5: CNI installieren

Installiere Cilium als Container Network Interface:

```bash
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium \
  --kubeconfig=pivot.kubeconfig \
  --namespace kube-system
```

**Was passiert:** Das Pivot-Cluster braucht ein CNI, damit Pods miteinander kommunizieren können. Ohne CNI bleiben die Nodes im Status "NotReady".

---

## ⚙️ Schritt 6: Cluster API im Pivot-Cluster initialisieren

Installiere Cluster API auch im Pivot-Cluster:

```bash
clusterctl --kubeconfig=pivot.kubeconfig init --infrastructure docker
```

**Was passiert:** Das Pivot-Cluster wird zum neuen Management-Cluster. Es kann jetzt selbst andere Cluster verwalten.

---

## 🔄 Schritt 7: Den eigentlichen Pivot durchführen

Verschiebe alle Cluster API-Ressourcen vom Bootstrap- zum Pivot-Cluster:

```bash
clusterctl move --to-kubeconfig=pivot.kubeconfig
```

**Was passiert:** clusterctl move verschiebt alle Cluster API-Objekte (wie Cluster, Machines, MachineDeployments) vom Source Management Cluster zum Target Management Cluster. Das Pivot-Cluster übernimmt jetzt die Verantwortung für alle verwalteten Cluster.

---

## ✅ Schritt 8: Pivot verifizieren

Prüfe, dass keine Cluster mehr im Bootstrap-Cluster sind:

```bash
kubectl get cluster
```

Ergebnis: **No resources found in default namespace.**

Prüfe, dass das Pivot-Cluster jetzt alle Cluster verwaltet:

```bash
kubectl --kubeconfig=pivot.kubeconfig get cluster
```

Ergebnis: Das **pivot**-Cluster erscheint in der Liste.

**Was bedeutet das:** Der Pivot war erfolgreich. Das Bootstrap-Cluster ist jetzt "leer" und kann gelöscht werden. Das Pivot-Cluster verwaltet sich selbst und alle anderen Cluster.

---

## 🧹 Schritt 9: Aufräumen (optional)

Bootstrap-Cluster löschen:

```bash
kind delete cluster --name bootstrap
```

**Was passiert:** Du löschst den temporären Bootstrap-Cluster. Das Pivot-Cluster läuft weiter und verwaltet sich selbst – das ist das Ziel des Pivot-Prozesses.

---

## 📝 Zusammenfassung

Der Pivot-Prozess löst das "Henne-Ei-Problem" des Cluster-Managements:

1. **Bootstrap**: Temporärer Cluster startet Cluster API
2. **Provision**: Bootstrap-Cluster erstellt dauerhaftes Ziel-Cluster
3. **Pivot**: Alle Verwaltungsaufgaben wandern zum Ziel-Cluster
4. **Cleanup**: Bootstrap-Cluster wird gelöscht

**Ergebnis:** Ein selbstverwaltender Management-Cluster, der andere Cluster erzeugen und verwalten kann.
