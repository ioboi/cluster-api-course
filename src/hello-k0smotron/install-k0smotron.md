# Install k0smotron

> [!NOTE]
> Full code of the example in this chapter is available [on GitHub](https://github.com/ioboi/cluster-api-course/tree/main/examples/hello-k0smotron).

If you built your [Course Environment](../course-environment/course-environment.md) you will need to install the k0smotron
`ControlPlaneProvider`, `BootstrapProvider` and `InfrastructureProvider`.

If you are on **macOS** or **Windows** you will need to re-create your `kind` cluster with the following configuration:

```yaml
{{#include ../../examples/hello-k0smotron/setup.sh:KindConfig}}
```

Here we add some `extraPortMappings`:

1. This port exposes the Kubernetes API of our control plane.
2. This port exposes Konnectivity.

### k0smotron `Namespace`

It is good practice to install our k0smotron components inside of a namespace.
Create a `Namespace` like this:

```yaml
{{#include ../../examples/hello-k0smotron/providers/k0smotron.yaml:Namespace}}
```

### k0smotron `ControlPlaneProvider`

Next we install `ControlPlaneProvider`:

```yaml
{{#include ../../examples/hello-k0smotron/providers/k0smotron.yaml:ControlPlaneProvider}}
```

The `ControlPlaneProvider` will manage our [`K0smotronControlPlane`](https://docs.k0smotron.io/stable/resource-reference/controlplane.cluster.x-k8s.io-v1beta1/#k0smotroncontrolplane)s.
The `K0smotronControlPlane` represents a hosted k0s control plane.
There is also a non-hosted control plane variant [`K0sControlPlane`](https://docs.k0smotron.io/stable/resource-reference/controlplane.cluster.x-k8s.io-v1beta1/#k0scontrolplane) available.

### k0smotron `BootstrapProvider`

We also need a way to bootstrap our worker nodes:

```yaml
{{#include ../../examples/hello-k0smotron/providers/k0smotron.yaml:BootstrapProvider}}
```

The bootstrap provider will generate the configuration to bootstrap k0s on any `Machine`.
In this example we will use [`K0sWorkerConfigTemplate`](https://docs.k0smotron.io/stable/resource-reference/bootstrap.cluster.x-k8s.io-v1beta1/#k0sworkerconfig) to configure our `MachineDeployment` managed worker nodes.

### k0smotron `InfrastructureProvider`

The last _optional_ component is the `InfrastructureProvider`:

```yaml
{{#include ../../examples/hello-k0smotron/providers/k0smotron.yaml:InfrastructureProvider}}
```

Although we won't use any of its provided functionality in this example it can still be interesting to experiment later. You can read more about [`RemoteMachine`s here](https://docs.k0smotron.io/stable/capi-remote/#cluster-api-remote-machine-provider).

## Provider Check

You can check your provider installation using the following command:

```bash
kubectl get coreproviders,controlplaneproviders,bootstrapproviders,infrastructureproviders --all-namespaces
```

The output should look like this:

```bash
$ kubectl get coreproviders,controlplaneproviders,bootstrapproviders,infrastructureproviders --all-namespaces
NAMESPACE     NAME                                                 INSTALLEDVERSION   READY
capi-system   coreprovider.operator.cluster.x-k8s.io/cluster-api   v1.12.3            True

NAMESPACE   NAME                                                                  INSTALLEDVERSION   READY
k0smotron   controlplaneprovider.operator.cluster.x-k8s.io/k0sproject-k0smotron   v1.10.3            True

NAMESPACE   NAME                                                               INSTALLEDVERSION   READY
k0smotron   bootstrapprovider.operator.cluster.x-k8s.io/k0sproject-k0smotron   v1.10.3            True

NAMESPACE                      NAME                                                                    INSTALLEDVERSION   READY
docker-infrastructure-system   infrastructureprovider.operator.cluster.x-k8s.io/docker                 v1.12.3            True
k0smotron                      infrastructureprovider.operator.cluster.x-k8s.io/k0sproject-k0smotron   v1.10.3            True

```

You should now be able to deploy your first hosted k0s control plane!
