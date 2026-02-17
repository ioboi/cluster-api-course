# Course Environment

## Prerequisites

Before getting started, you will need the following tools installed on your system:

- A container engine such as [Docker](https://www.docker.com/get-started/)
- A tool for running local Kubernetes like [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl), if not already provided by your tool to run Kubernetes locally
- [Helm](https://helm.sh/docs/intro/install) to install Helm charts

## Create `kind` Cluster

Most examples in this course use [Cluster API Provider Docker (CAPD)](https://github.com/kubernetes-sigs/cluster-api/blob/main/test/infrastructure/docker/README.md) as the infrastructure provider.
Because CAPD will create Kubernetes nodes as containers, it needs access to your local Docker socket (for example `/var/run/docker.sock`).
This requires creating a `kind` cluster that mounts the Docker socket to its nodes.
You can achieve this by creating a `config.yaml` for your `kind` cluster:

```yaml
{{#include ../../examples/cluster-api-operator/config.yaml}}
```

Create a new cluster using this configuration:

```bash
{{#include ../../examples/cluster-api-operator/setup.sh:create-cluster}}
```

## Install cert-manager

Before installing the [Cluster API Operator](https://cluster-api-operator.sigs.k8s.io/)
you will need to install cert-manager:

```bash
{{#include ../../examples/cluster-api-operator/setup.sh:cert-manager}}
```

Ensure that cert-manager is up and running:

```bash
{{#include ../../examples/cluster-api-operator/setup.sh:wait-for-cert-manager}}
```

After some time you should be able to see the following output:

```bash
deployment.apps/cert-manager condition met
deployment.apps/cert-manager-cainjector condition met
deployment.apps/cert-manager-webhook condition met
```

## Install the Cluster API Operator

Next you can finally install the Cluster API Operator.
First you will need to add the CAPI Operator Helm repository:

```bash
{{#include ../../examples/cluster-api-operator/setup.sh:helm-repo-add}}
```

Deploy the Cluster API components with the CAPD enabled:

```bash
{{#include ../../examples/cluster-api-operator/setup.sh:helm-install}}
```

The Cluster API Operator provides several useful APIs to manage your CAPI components declaratively.
The most important ones are:

- [`CoreProvider`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api-operator/operator.cluster.x-k8s.io/CoreProvider/v1alpha2@v0.24.1)
- [`BootstrapProvider`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api-operator/operator.cluster.x-k8s.io/BootstrapProvider/v1alpha2@v0.24.1)
- [`ControlPlaneProvider`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api-operator/operator.cluster.x-k8s.io/ControlPlaneProvider/v1alpha2@v0.24.1)
- [`InfrastructureProvider`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api-operator/operator.cluster.x-k8s.io/InfrastructureProvider/v1alpha2@v0.24.1)

## Check CAPD

It takes some time until every component of the Cluster API is up and running.
You can wait for CAPD to be ready using the following command:

```bash
{{#include ../../examples/cluster-api-operator/setup.sh:wait-for-capd}}
```

## Check Namespaces

After this setup your cluster should have a lot more namespaces:

```bash
$ {{#include ../../examples/cluster-api-operator/setup.sh:ns}}

NAME                                STATUS   AGE
capi-kubeadm-bootstrap-system       Active   69m
capi-kubeadm-control-plane-system   Active   69m
capi-operator-system                Active   69m
capi-system                         Active   69m
cert-manager                        Active   69m
default                             Active   69m
docker-infrastructure-system        Active   69m
kube-node-lease                     Active   69m
kube-public                         Active   69m
kube-system                         Active   69m
local-path-storage                  Active   69m
```

Congratulations 🎉 You now have a local, working course environment.
