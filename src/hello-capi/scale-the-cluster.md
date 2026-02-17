# Scale the Cluster

> [!WARNING]
> Skip this chapter if you do not have at least 6 GB of RAM.

CAPI makes it easy to scale out our created cluster.
A highly available Kubernetes cluster needs at least 3 control plane and 2 worker nodes.

## Scale the Control Plane

Here are two methods to scale our control plane.

The first way to scale is by using `kubectl scale`:

```
kubectl scale kubeadmcontrolplane example --replicas=3
```

Another way is to edit the current `KubeadmControlPlane` and specify `replicas: 3`:

```yaml
{{#include ../../examples/hello-capd/scaled-control-plane.yaml}}
```

## Scale our Worker Nodes

We can scale our worker nodes the same way as we did with our control plane.

```
kubectl scale machinedeployment example-workers --replicas=2
```

Or again just by updating the current `MachineDeployment`:

```yaml
{{#include ../../examples/hello-capd/scaled-workers.yaml}}
```

## The Scaled Cluster

At the end our cluster should look like this:

```bash
$ kubectl get cluster,machine
NAME      CLUSTERCLASS   AVAILABLE   CP DESIRED   CP AVAILABLE   CP UP-TO-DATE   W DESIRED   W AVAILABLE   W UP-TO-DATE   PHASE         AGE   VERSION
example                  False       3            0              3               3           0             3              Provisioned   49m

NAME                                                   CLUSTER   NODE NAME                     READY   AVAILABLE   UP-TO-DATE   PHASE     AGE     VERSION
machine.cluster.x-k8s.io/example-svckq                 example   example-svckq                 False   False       True         Running   50m     v1.34.0
machine.cluster.x-k8s.io/example-tclhv                 example   example-tclhv                 False   False       True         Running   55m     v1.34.0
machine.cluster.x-k8s.io/example-tlff5                 example   example-tlff5                 False   False       True         Running   55m     v1.34.0

machine.cluster.x-k8s.io/example-workers-pzfk7-kn9tp   example   example-workers-pzfk7-kn9tp   False   False       True         Running   51m     v1.34.0
machine.cluster.x-k8s.io/example-workers-pzfk7-7hsrb   example   example-workers-pzfk7-7hsrb   False   False       True         Running   56m     v1.34.0
```
