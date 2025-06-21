# k0smotron

[k0smotron](https://docs.k0smotron.io/stable/) ist ein Open-Source-Kubernetes-Operator, der als Cluster API Provider arbeitet.
Das Tool nutzt eine Kubernetes-in-Kubernetes-Architektur:
Control Planes laufen als Container-Pods in bestehenden Management-Clustern,
statt separate Infrastruktur zu benötigen.

![k0smotron architecture](https://docs.k0smotron.io/stable/img/k0smotron.png)

## 📋 Installation

```bash
clusterctl init --bootstrap k0sproject-k0smotron \
                --control-plane k0sproject-k0smotron \
                --infrastructure k0sproject-k0smotron
```

---

```bash
clusterctl init --bootstrap k0sproject-k0smotron --control-plane k0sproject-k0smotron --infrastructure k0sproject-k0smotron
```

[Per-module installation for Cluster API](https://docs.k0smotron.io/stable/install/#per-module-installation-for-cluster-api)

## ⎈ Mein erstes k0s Cluster

```yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: docker-test
  namespace: default
spec:
  controlPlaneRef:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta1
    kind: K0smotronControlPlane
    name: docker-test-cp
    namespace: default
  infrastructureRef:
    apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
    kind: DockerCluster
    name: docker-test
    namespace: default
---
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: K0smotronControlPlane # This is the config for the controlplane
metadata:
  name: docker-test-cp
  namespace: default
spec:
  version: v1.33.1+k0s.1
  persistence:
    type: emptyDir
  service:
    type: NodePort
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: DockerCluster
metadata:
  name: docker-test
  namespace: default
  annotations:
    cluster.x-k8s.io/managed-by: k0smotron # This marks the base infra to be self managed. The value of the annotation is irrelevant, as long as there is a value.
---
apiVersion: cluster.x-k8s.io/v1beta1
kind: MachineDeployment
metadata:
  name: docker-test-md
  namespace: default
spec:
  clusterName: docker-test
  replicas: 1
  selector:
    matchLabels:
      cluster.x-k8s.io/cluster-name: docker-test
      pool: worker-pool-1
  template:
    metadata:
      labels:
        cluster.x-k8s.io/cluster-name: docker-test
        pool: worker-pool-1
    spec:
      clusterName: docker-test
      version: v1.33.1
      bootstrap:
        configRef:
          apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
          kind: K0sWorkerConfigTemplate
          name: docker-test-machine-config
      infrastructureRef:
        apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
        kind: DockerMachineTemplate
        name: docker-test-mt
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: DockerMachineTemplate
metadata:
  name: docker-test-mt
  namespace: default
spec:
  template:
    spec: {}
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: K0sWorkerConfigTemplate
metadata:
  name: docker-test-machine-config
spec:
  template:
    spec:
      version: v1.33.1+k0s.1
```

[Beispiel angelehnt an: Creating a child cluster](https://docs.k0smotron.io/stable/capi-docker/#creating-a-child-cluster)
