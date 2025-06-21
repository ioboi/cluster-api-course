# Cluster Template mit ClusterClass

ClusterClass verwandelt die Cluster-Verwaltung: Statt zehn einzelne Ressourcen zu erstellen, reicht eine einzige Vorlage.

## 🎯 Was ist ClusterClass?

ClusterClass ist eine **experimentelle Funktion** der Cluster API. Sie definiert Cluster-Vorlagen, die mehrfach verwendet werden können.

**Früher:** 10+ YAML-Dateien für ein Cluster
**Jetzt:** 1 ClusterClass + 1 Cluster-Definition

### Der Kerngedanke

Du schreibst einmal eine Cluster-Vorlage. Teams nutzen sie beliebig oft:

```yaml
# Einmal definieren
kind: ClusterClass
metadata:
  name: standard-cluster-v1

# Oft verwenden
kind: Cluster
spec:
  topology:
    class: standard-cluster-v1
    version: v1.33.1
    controlPlane:
      replicas: 3
    workers:
      machineDeployments:
      - class: default-worker
        replicas: 5
```

## 🏗️ Architektur-Bausteine

Eine ClusterClass besteht aus vier Teilen:

| Baustein           | Zweck                       | Beispiel                       |
| ------------------ | --------------------------- | ------------------------------ |
| **Infrastructure** | Netzwerk, Load Balancer     | DockerClusterTemplate          |
| **Control Plane**  | API-Server, etcd, Scheduler | KubeadmControlPlaneTemplate    |
| **Workers**        | Worker-Node-Gruppen         | MachineDeployment-Klassen      |
| **Variables**      | Anpassbare Parameter        | Region, Instance-Typ, Netzwerk |

### Variables und Patches

**Variables** machen Templates flexibel:

```yaml
variables:
  - name: region
    required: true
    schema:
      openAPIV3Schema:
        type: string
        enum: ["us-east-1", "eu-west-1"]
  - name: networking
    schema:
      openAPIV3Schema:
        type: object
        properties:
          podCIDR:
            type: string
            default: "192.168.0.0/16"
          serviceCIDR:
            type: string
            default: "10.128.0.0/12"
          cniPlugin:
            type: string
            enum: ["calico", "cilium", "kindnet"]
            default: "kindnet"
```

**Patches** passen Templates an:

```yaml
patches:
  - name: region-config
    definitions:
      - selector:
          kind: DockerClusterTemplate
        jsonPatches:
          - op: replace
            path: /spec/template/spec/loadBalancer
            valueFrom:
              variable: region
  - name: custom-networking
    enabledIf: '{{ ne .networking.cniPlugin "kindnet" }}'
    definitions:
      - selector:
          apiVersion: controlplane.cluster.x-k8s.io/v1beta1
          kind: KubeadmControlPlaneTemplate
        jsonPatches:
          - op: add
            path: /spec/template/spec/kubeadmConfigSpec/clusterConfiguration/networking
            valueFrom:
              template: |
                podSubnet: "{{ .networking.podCIDR }}"
                serviceSubnet: "{{ .networking.serviceCIDR }}"
```

## ⚠️ Status: Experimentell

ClusterClass ist **Alpha-Feature** und benötigt:

```bash
export CLUSTER_TOPOLOGY=true
clusterctl init --infrastructure docker
```

**Wichtig:** Produktive Nutzung auf eigenes Risiko.

## 🔨 k0smotron-Beispiel: Erste ClusterClass

### Schritt 1: Supporting Templates erstellen

Zuerst die Templates, die die ClusterClass referenziert:

```yaml
# Speichere als k0smotron-templates.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: K0sControlPlaneTemplate
metadata:
  name: k0s-controlplane-template
spec:
  template:
    spec:
      k0sConfigSpec:
        k0s:
          apiVersion: k0s.k0sproject.io/v1beta1
          kind: ClusterConfig
          metadata:
            name: k0s
          spec:
            api:
              extraArgs:
                anonymous-auth: "true" # Benötigt für Health-Checks
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: DockerMachineTemplate
metadata:
  name: cp-docker-machine-template
  namespace: default
spec:
  template:
    spec: {}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: DockerClusterTemplate
metadata:
  name: docker-cluster-template
spec:
  template:
    spec: {}
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: K0sWorkerConfigTemplate
metadata:
  name: k0s-worker-config-template
  namespace: default
spec:
  template:
    spec:
      version: v1.33.1+k0s.1
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: DockerMachineTemplate
metadata:
  name: worker-docker-machine-template
  namespace: default
spec:
  template:
    spec: {}
```

### Schritt 2: k0smotron ClusterClass

```yaml
# Speichere als k0smotron-clusterclass.yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: ClusterClass
metadata:
  name: k0smotron-clusterclass
spec:
  controlPlane:
    ref:
      apiVersion: controlplane.cluster.x-k8s.io/v1beta1
      kind: K0sControlPlaneTemplate
      name: k0s-controlplane-template
      namespace: default
    machineInfrastructure:
      ref:
        kind: DockerMachineTemplate
        apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
        name: cp-docker-machine-template
        namespace: default
  infrastructure:
    ref:
      apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
      kind: DockerClusterTemplate
      name: docker-cluster-template
      namespace: default
  workers:
    machineDeployments:
      - class: default-worker
        template:
          bootstrap:
            ref:
              apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
              kind: K0sWorkerConfigTemplate
              name: k0s-worker-config-template
              namespace: default
          infrastructure:
            ref:
              apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
              kind: DockerMachineTemplate
              name: worker-docker-machine-template
              namespace: default
```

### Schritt 3: Cluster aus k0smotron ClusterClass

```yaml
# Speichere als k0s-cluster.yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: k0s-test-cluster
spec:
  clusterNetwork:
    pods:
      cidrBlocks: ["192.168.0.0/16"]
    services:
      cidrBlocks: ["10.128.0.0/12"]
  topology:
    class: k0smotron-clusterclass
    version: v1.33.1+k0s.1
    controlPlane:
      replicas: 1
    workers:
      machineDeployments:
        - class: default-worker
          name: worker-pool
          replicas: 2
```

### Schritt 4: Anwenden und prüfen

```bash
# Templates anwenden
kubectl apply -f k0smotron-templates.yaml

# ClusterClass anwenden
kubectl apply -f k0smotron-clusterclass.yaml

# Cluster erstellen
kubectl apply -f k0s-cluster.yaml

# Status verfolgen
kubectl get clusterclass
kubectl get cluster k0s-test-cluster
kubectl get k0scontrolplane
kubectl get machinedeployment

# Kubeconfig abrufen (wenn Cluster ready)
clusterctl get kubeconfig k0s-test-cluster > k0s-kubeconfig
kubectl --kubeconfig=k0s-kubeconfig get nodes
```

ClusterClass verwandelt die Cluster-Verwaltung: Statt zehn einzelne Ressourcen zu erstellen, reicht eine einzige Vorlage.
