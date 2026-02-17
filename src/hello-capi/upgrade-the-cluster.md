# Upgrade the Cluster

In this chapter we will upgrade our cluster from Kubernetes [v1.34.0](https://github.com/kubernetes/kubernetes/releases/tag/v1.34.0) to [v1.35.0](https://github.com/kubernetes/kubernetes/releases/tag/v1.35.0).

## Upgrade the Control Plane

We will first upgrade our control plane.
This can be achieved by updating the version of our `KubeadmControlPlane`:

```diff
apiVersion: controlplane.cluster.x-k8s.io/v1beta2
kind: KubeadmControlPlane
metadata:
  namespace: default
  name: example
spec:
-  version: "1.34.0"
+  version: "1.35.0"
  machineTemplate:
  ...
```

This change will trigger a rolling upgrade of the control plane.

## Upgrade `MachineDeployment`

You can upgrade the `MachineDeployment` by updating the version:

```diff
apiVersion: cluster.x-k8s.io/v1beta2
kind: MachineDeployment
metadata:
  name: example-workers
  namespace: default
spec:
  ...
  template:
    ...
    spec:
      clusterName: example
-      version: v1.34.0
+      version: v1.35.0
    ...
```

> [!CAUTION]
> In a production setting the upgrade will be a bit more complex.
>
> [Machine- and bootstrap-templates should be considered immutable.](https://cluster-api.sigs.k8s.io/tasks/updating-machine-templates#updating-machine-infrastructure-and-bootstrap-templates)

## Check Versions

You can check the state of your upgrade with the following command:

```bash
$ kubectl get cluster,machine,machinedeployment

NAME                               CLUSTERCLASS   AVAILABLE   CP DESIRED   CP AVAILABLE   CP UP-TO-DATE   W DESIRED   W AVAILABLE   W UP-TO-DATE   PHASE         AGE   VERSION
cluster.cluster.x-k8s.io/example                  False       3            0              3               2           0             2              Provisioned   87m

NAME                                                   CLUSTER   NODE NAME                     READY   AVAILABLE   UP-TO-DATE   PHASE     AGE     VERSION
machine.cluster.x-k8s.io/example-jtsh7                 example   example-jtsh7                 False   False       True         Running   8m55s   v1.35.0
machine.cluster.x-k8s.io/example-mm8vz                 example   example-mm8vz                 False   False       True         Running   8m12s   v1.35.0
machine.cluster.x-k8s.io/example-snxnj                 example   example-snxnj                 False   False       True         Running   9m28s   v1.35.0
machine.cluster.x-k8s.io/example-workers-29xqx-nzxwf   example   example-workers-29xqx-nzxwf   False   False       True         Running   12s     v1.35.0
machine.cluster.x-k8s.io/example-workers-29xqx-sjpnt   example   example-workers-29xqx-sjpnt   False   False       True         Running   6m40s   v1.35.0

NAME                                                 CLUSTER   AVAILABLE   DESIRED   CURRENT   READY   AVAILABLE   UP-TO-DATE   PHASE     AGE   VERSION
machinedeployment.cluster.x-k8s.io/example-workers   example   False       2         2         0       0           2            Running   87m   v1.35.0
```
