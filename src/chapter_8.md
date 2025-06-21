# Cluster-Lifecycle steuern

Das Management von Kubernetes-Clustern über ihren gesamten Lebenszyklus ist ein Kernbereich der Cluster API. Du lernst hier, wie du Cluster skalierst, aktualisierst und reparierst – alles deklarativ über YAML.

## 🔄 Der Reconcile Loop verstehen

Die Cluster API arbeitet nach dem Controller-Pattern. Jeder Controller überwacht "seine" Ressourcen und gleicht kontinuierlich den gewünschten Zustand mit der Realität ab.

**Beispiel**: Du änderst `spec.replicas` von 2 auf 4 Worker-Nodes:

1. Controller erkennt die Differenz (2 vs. 4)
2. Controller erstellt 2 neue `Machine`-Ressourcen
3. Infrastructure Provider startet 2 neue VMs/Container
4. Bootstrap Provider konfiguriert die neuen Nodes
5. Neue Nodes joinen das Cluster

Dieser Prozess läuft automatisch – du musst nur den gewünschten Zustand definieren.

## 📈 Cluster skalieren

### Worker-Nodes hinzufügen

Skaliere das Cluster mit clusterctl:

```bash
# Worker-Nodes auf 3 erhöhen
clusterctl alpha rollout restart machinedeployment/my-cluster-md-0
# Oder direktes Scaling über kubectl
kubectl scale machinedeployment my-cluster-md-0 --replicas=3
```

Status verfolgen:

```bash
clusterctl describe cluster my-cluster
kubectl get machines
```

### Control-Plane skalieren

Für hochverfügbare Cluster skalierst du die Control-Plane:

```bash
kubectl scale kubeadmcontrolplane my-cluster-control-plane --replicas=3
```

**Wichtig**: Control-Plane-Nodes sollten immer in ungerader Anzahl laufen (1, 3, 5) wegen etcd-Quorum.

## ⬆️ Kubernetes-Version upgraden

### Control-Plane upgraden

```bash
# Kubernetes-Version auf v1.31.2 upgraden
clusterctl alpha rollout restart kubeadmcontrolplane/my-cluster-control-plane
```

Der Controller führt das Upgrade automatisch durch:

- Erstellt neue Control-Plane-Node mit neuer Version
- Migriert etcd-Daten
- Entfernt alte Control-Plane-Node
- Wiederholt den Prozess für alle Control-Plane-Nodes

### Worker-Nodes upgraden

```bash
# Worker-Nodes upgraden
clusterctl alpha rollout restart machinedeployment/my-cluster-md-0
```

**Rolling Updates**: Worker-Nodes werden schrittweise ersetzt, um die Verfügbarkeit zu gewährleisten.

## 🔍 Status und Debugging

### Cluster-Status prüfen

```bash
# Überblick über alle Cluster
clusterctl describe cluster

# Details zu einem bestimmten Cluster
clusterctl describe cluster my-cluster

# Machine-Status
kubectl get machines -o wide
```

### Controller-Logs lesen

Bei Problemen helfen die Controller-Logs:

```bash
# Core Cluster API Controller
kubectl logs -n capi-system deployment/capi-controller-manager -f

# Control-Plane Controller
kubectl logs -n capi-kubeadm-control-plane-system \
  deployment/capi-kubeadm-control-plane-controller-manager -f

# Infrastructure Provider (CAPD)
kubectl logs -n capd-system deployment/capd-controller-manager -f
```

## 🚨 Probleme beheben

### Hängende Machines

Manchmal bleiben Machines in `Provisioning` oder `Failed` hängen:

```bash
# Machine-Details anschauen
kubectl describe machine <machine-name>

# Zugehörige DockerMachine prüfen
kubectl describe dockermachine <dockermachine-name>

# Bei Bedarf Machine löschen (wird neu erstellt)
kubectl delete machine <machine-name>
```

### Control-Plane-Probleme

```bash
# Control-Plane-Status prüfen
kubectl describe kubeadmcontrolplane my-cluster-control-plane

# etcd-Status im Workload-Cluster prüfen
kubectl --kubeconfig=kubeconfig-workload get pods -n kube-system
```

### Node-Probleme im Workload-Cluster

```bash
# Nodes im Workload-Cluster prüfen
kubectl --kubeconfig=kubeconfig-workload get nodes

# Node-Details anschauen
kubectl --kubeconfig=kubeconfig-workload describe node <node-name>
```

## 🔧 Maintenance-Modi

### Cluster zwischen Management-Clustern verschieben

Mit `clusterctl move` verschiebst du Cluster zwischen verschiedenen Management-Clustern:

```bash
# Aktuelles Management-Cluster (Quelle)
kubectl config use-context source-mgmt-cluster

# Ziel-Management-Cluster vorbereiten
kubectl config use-context target-mgmt-cluster
clusterctl init --infrastructure docker

# Zurück zur Quelle wechseln
kubectl config use-context source-mgmt-cluster

# Cluster verschieben
clusterctl move --to-kubeconfig ~/.kube/target-mgmt-config

# Oder spezifisches Cluster verschieben
clusterctl move --to-kubeconfig ~/.kube/target-mgmt-config \
  --filter cluster=my-cluster
```

**Pivot-Prozess**: Der Pivot-Prozess verschiebt Provider-Komponenten und Cluster API Ressourcen von einem Quell-Management-Cluster zu einem Ziel-Management-Cluster.

### Machine-Health-Checks

Cluster API kann unhealthy Nodes automatisch ersetzen:

```yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: MachineHealthCheck
metadata:
  name: my-cluster-worker-health-check
spec:
  clusterName: my-cluster
  selector:
    matchLabels:
      cluster.x-k8s.io/deployment-name: my-cluster-md-0
  unhealthyConditions:
    - type: Ready
      status: Unknown
      timeout: 300s
    - type: Ready
      status: "False"
      timeout: 300s
  maxUnhealthy: 40%
  nodeStartupTimeout: 10m
```
