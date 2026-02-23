# Hello k0smotron Cluster

> [!NOTE]
> Full code of the example in this chapter is available [on GitHub](https://github.com/ioboi/cluster-api-course/tree/main/examples/hello-k0smotron).

## Let's Start without a `DockerMachineTemplate`?!

We don't need a `DockerMachineTemplate` to run our control plane nodes on because our control planes will run as pods inside our management cluster.

## Define the Control Plane

Instead of creating machines, we can specify our [`K0smotronControlPlane`](https://docs.k0smotron.io/stable/resource-reference/controlplane.cluster.x-k8s.io-v1beta1/):

```yaml
{{#include ../../examples/hello-k0smotron/k0s.yaml:K0smotronControlPlane}}
```

1. `v1.35.1+k0s.0` is the target k0s Kubernetes version.
2. Data related to the cluster will be persisted in an [emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir). Note that `emptyDir` data is lost if the pod is rescheduled. For production use cases, consider using a `PersistentVolumeClaim` instead.
3. The `Service` exposing our control plane will be of [`type: NodePort`](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport). This means our control plane will be available on an unprivileged port number on our management cluster node. The port number is by [default `30443` for the API server, `30132` for konnectivity](https://docs.k0smotron.io/stable/resource-reference/controlplane.cluster.x-k8s.io-v1beta1/#k0smotroncontrolplanespecservice).

## The `DockerCluster`

Although at the moment we only want to create a control plane we still need to configure a [`DockerCluster`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/infrastructure.cluster.x-k8s.io/DockerCluster/v1beta2@v1.12.2):

```yaml
{{#include ../../examples/hello-k0smotron/k0s.yaml:DockerCluster}}
```

1. With the annotation `cluster.x-k8s.io/managed-by` we can mark a `InfraCluster` to be managed by another system. The value here is irrelevant. Read more about the annotation at [Supported Annotations](https://cluster-api.sigs.k8s.io/reference/api/labels-and-annotations#supported-annotations).

## Tie Everything Together With `Cluster`

The last piece for our hosted control plane is a [`Cluster`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/cluster.x-k8s.io/Cluster/v1beta2@v1.12.2).
The `Cluster` connects the control plane with the infrastructure.

```yaml
{{#include ../../examples/hello-k0smotron/k0s.yaml:Cluster}}
```

## Create the Cluster

After we applied all our resources we can check the cluster state with the following command:

```bash
kubectl get cluster
```

The output of this command should look like this:

```bash
$ kubectl get cluster

NAME          CLUSTERCLASS   AVAILABLE   CP DESIRED   CP AVAILABLE   CP UP-TO-DATE   W DESIRED   W AVAILABLE   W UP-TO-DATE   PHASE         AGE     VERSION
k0s-example                  True        1            1              1               0           0             0              Provisioned   7m55s
```

It takes some time for the control plane to become available.

Let's take a look at our control plane components:

```bash
$ kubectl get pods

NAME                     READY   STATUS    RESTARTS   AGE
kmc-k0s-example-0        1/1     Running   0          8m50s
kmc-k0s-example-etcd-0   1/1     Running   0          8m50s
```

As you can see we have two pods running:

- **kmc-k0s-example-0** Running k0s as a control plane.
- **kmc-k0s-example-etcd-0** The etcd backing our control plane.

Next we will access our hosted control plane.
