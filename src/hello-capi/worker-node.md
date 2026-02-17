# Add a Worker Node

Now that we have a cluster up and running, we should
add a worker node to be able to schedule workloads on our cluster.

## Our First `MachineDeployment`

The relationship between [`MachineDeployment`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/cluster.x-k8s.io/MachineDeployment/v1beta2@v1.12.2) and [`Machine`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/cluster.x-k8s.io/Machine/v1beta2@v1.12.2) is modeled after the relationship between [`Deployment`](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) and [`Pod`](https://kubernetes.io/docs/concepts/workloads/pods/).
A `MachineDeployment` manages a number of `Machine` replicas.
These replicas are created using a `Machine` template.

Create a `MachineDeployment` like this:

```yaml
{{#include ../../examples/hello-capd/example-cluster.yaml:MachineDeployment}}
```

1. The cluster these worker nodes belong to.
2. `v1.34.0` specifies the target Kubernetes version of the worker nodes.
3. Specifies the [`KubeadmConfigTemplate`](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api/bootstrap.cluster.x-k8s.io/KubeadmConfigTemplate/v1beta2@v1.12.2) used to bootstrap the worker nodes.
4. References the used infrastructure.

For this example our `KubeadmConfigTemplate` is empty:

```yaml
{{#include ../../examples/hello-capd/example-cluster.yaml:KubeadmConfigTemplate}}
```

When you apply these manifests to your local cluster, a new worker node should be created and connected to your cluster.

```bash
$ kubectl get cluster,machine
NAME      CLUSTERCLASS   AVAILABLE   CP DESIRED   CP AVAILABLE   CP UP-TO-DATE   W DESIRED   W AVAILABLE   W UP-TO-DATE   PHASE         AGE   VERSION
example                  False       1            0              1               1           0             1              Provisioned   49m

NAME                                                   CLUSTER   NODE NAME                     READY   AVAILABLE   UP-TO-DATE   PHASE     AGE     VERSION
machine.cluster.x-k8s.io/example-svckq                 example   example-svckq                 False   False       True         Running   50m     v1.34.0
machine.cluster.x-k8s.io/example-workers-pzfk7-kn9tp   example   example-workers-pzfk7-kn9tp   False   False       True         Running   51m     v1.34.0
```
