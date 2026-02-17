# Hello Cluster

> [!NOTE]
> Full code of the example in this chapter is available [on GitHub](https://github.com/ioboi/cluster-api-course/tree/main/examples/hello-capd).

## Start with the `DockerMachineTemplate`

Before we can create a cluster, we need infrastructure to run the Kubernetes components on.
For our example, we will create a [`DockerMachineTemplate`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/infrastructure.cluster.x-k8s.io/DockerMachineTemplate/v1beta2@v1.12.2)
that looks like this:

```yaml
{{#include ../../examples/hello-capd/example-cluster.yaml:DockerMachineTemplate}}
```

As you can see, it is an empty `template.spec`.
There is a multitude of options that could be configured for our `DockerMachines`.
Possible fields can be found in [documentation of the `spec`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/infrastructure.cluster.x-k8s.io/DockerMachineTemplate/v1beta2@v1.12.2#spec-template-spec).

## The Control Plane

Next, we specify our control plane.
In this example, we will use a
[`KubeadmControlPlane`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/controlplane.cluster.x-k8s.io/KubeadmControlPlane/v1beta2@v1.12.2)
that looks like this:

```yaml
{{#include ../../examples/hello-capd/example-cluster.yaml:KubeadmControlPlane}}
```

1. `1.34.0` is the target Kubernetes version.
2. Our control plane will run on the default-machine-template that we specified earlier.
3. Make the generated certificate valid for localhost access.

## The InfraCluster

With the control plane specified, we need the last part of a valid Cluster API [`Cluster`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/cluster.x-k8s.io/Cluster/v1beta2@v1.12.2), the InfraCluster.

> The goal of an InfraCluster resource is to supply whatever prerequisites (in term of infrastructure) are necessary for running machines. Examples might include networking, load balancers, firewall rules, and so on.
>
> [Source: Contract rules for InfraCluster, The Cluster API Book](https://cluster-api.sigs.k8s.io/developer/providers/contracts/infra-cluster)

In our case, we specify a [`DockerCluster`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/infrastructure.cluster.x-k8s.io/DockerCluster/v1beta2@v1.12.2).

```yaml
{{#include ../../examples/hello-capd/example-cluster.yaml:DockerCluster}}
```

## The Cluster

With both the control plane and infra cluster configured, we are now able to create the core resource of the Cluster API: the [`Cluster`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/cluster.x-k8s.io/Cluster/v1beta2@v1.12.2).

```yaml
{{#include ../../examples/hello-capd/example-cluster.yaml:Cluster}}
```

As you can see, the `Cluster` just references the control plane (1) and the InfraCluster (2).

## Create the Cluster

After you apply all resources, you can watch the current state of the cluster using the following command:

```bash
$ kubectl get cluster
NAME      CLUSTERCLASS   AVAILABLE   CP DESIRED   CP AVAILABLE   CP UP-TO-DATE   W DESIRED   W AVAILABLE   W UP-TO-DATE   PHASE         AGE   VERSION
example                  False       1            0              1               1           0             1              Provisioned   49m
```

Don't worry about `AVAILABLE False` for the moment, because our created cluster does not have a [Container Networking Interface (CNI)](https://github.com/containernetworking/cni) installed.

And if you want to peek behind the scenes you can see that some containers were created:

```bash
$ docker ps
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS          PORTS                                              NAMES
b7de5a0f8bfe   kindest/node:v1.34.0                 "/usr/local/bin/entr…"   50 minutes ago   Up 50 minutes   127.0.0.1:32772->6443/tcp                          example-4nfrx
0f2c8d92ddd3   kindest/haproxy:v20230606-42a2262b   "haproxy -W -db -f /…"   50 minutes ago   Up 50 minutes   0.0.0.0:32770->6443/tcp, 0.0.0.0:32771->8404/tcp   example-lb
786cef0cd942   kindest/node:v1.35.0                 "/usr/local/bin/entr…"   59 minutes ago   Up 59 minutes   127.0.0.1:51439->6443/tcp                          kind-control-plane
```

In this example, the first container with the generated name `example-4nfrx` is our control plane node.
The second container `example-lb` is a load balancer for our control plane node and will be used to connect to our control plane.
The last container is our `kind` cluster that's running CAPI.
