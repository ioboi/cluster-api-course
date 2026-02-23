# Add a Worker Node

> [!WARNING]
> This only works on Linux at the moment.

To run any workload on our cluster we need to add at least one worker node.

## `DockerMachineTemplate`

We need infrastructure to run the Kubernetes worker components on.
For our example, we will create a `DockerMachineTemplate` that looks like this:

```yaml
{{#include ../../examples/hello-k0smotron/k0s.yaml:DockerMachineTemplate}}
```

This will create a container as a node when used.

## `MachineDeployment`

Next we create a `MachineDeployment`. As already explained in [Hello CAPI: Add a Worker Node](../hello-capi/worker-node.md),
the `MachineDeployment` relates to `Machine`s as `Deployment` relates to `Pod`s (both create a `<>ReplicaSet` that in turn manages a set of `Machine`s/`Pod`s).

```yaml
{{#include ../../examples/hello-k0smotron/k0s.yaml:MachineDeployment}}
```

And for the bootstrap configuration we will use the following `K0sWorkerConfigTemplate`:

```yaml
{{#include ../../examples/hello-k0smotron/k0s.yaml:K0sWorkerConfigTemplate}}
```

> [!NOTE]
> In `MachineDeployment.spec.template.spec.version` we specify the version of the `kind` node container image.
> In `K0sWorkerConfigTemplate.spec.template.spec.version` we specify the version of k0s.

## On the Management Cluster

After we applied our manifests we now should see a new `Machine`:

```bash
$ kubectl get cluster,machine

NAME                                   CLUSTERCLASS   AVAILABLE   CP DESIRED   CP AVAILABLE   CP UP-TO-DATE   W DESIRED   W AVAILABLE   W UP-TO-DATE   PHASE         AGE   VERSION
cluster.cluster.x-k8s.io/k0s-example                  True        1            1              1               1           1             1              Provisioned   75m

NAME                                                       CLUSTER       NODE NAME                         READY   AVAILABLE   UP-TO-DATE   PHASE     AGE     VERSION
machine.cluster.x-k8s.io/k0s-example-workers-6692x-8ncxd   k0s-example   k0s-example-workers-6692x-8ncxd   True    True        True         Running   8m54s   v1.35.1
```

## On the Cluster

If we take a look at the `Pod`s and `Node`s inside our hosted control plane cluster:

```bash
$ kubectl --kubeconfig config-k0s-example get pods,nodes --all-namespaces
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   pod/coredns-55c758887c-xlwkk         1/1     Running   0          75m
kube-system   pod/konnectivity-agent-vqgls         1/1     Running   0          9m8s
kube-system   pod/kube-proxy-nn8nc                 1/1     Running   0          9m8s
kube-system   pod/kube-router-grqmq                1/1     Running   0          9m8s
kube-system   pod/metrics-server-df68c566c-wgbr6   1/1     Running   0          75m

NAMESPACE   NAME                                   STATUS   ROLES    AGE    VERSION
            node/k0s-example-workers-6692x-8ncxd   Ready    <none>   9m8s   v1.35.1+k0s
```

There is a new `Node` called "node/k0s-example-workers-6692x-8ncxd" (note: this name is generated).
