# k0s and k0smotron

> [!TIP]
> Read more about [k0s here](https://docs.k0sproject.io/stable/) and [k0smotron here](https://docs.k0smotron.io/stable/).

We will implement our hosted control plane Kubernetes cluster using both [k0s](https://k0sproject.io/) and [k0smotron](https://k0smotron.io/).

## k0s

k0s is a certified Kubernetes distribution.
It originated at [Mirantis](https://www.mirantis.com/) and was later donated to the CNCF.
At the moment, k0s is a [CNCF Sandbox](https://www.cncf.io/sandbox-projects/) project.

## k0smotron

k0smotron is a Kubernetes Operator that allows you to manage Kubernetes control planes.
It can be either run by itself or act as a Cluster API `ControlPlaneProvider`, `BootstrapProvider` and `InfrastructureProvider`.

![k0smotron architecture](https://docs.k0smotron.io/stable/img/k0smotron.png)

k0smotron runs on a management cluster and will manage k0s control planes on it.
These k0s control planes are exposed via `Service`.
This `Service` needs to be reachable by the worker nodes.

Worker nodes run outside of the management cluster.
This also means that they can be run on separate infrastructure.
The only requirement is connectivity to the hosted control plane.

Control plane and worker nodes are connected via Konnectivity.
Konnectivity is a TCP level proxy for the control plane cluster communication and is a replacement to SSH tunnels.
You can read more about it in [Konnectivity service](https://kubernetes.io/docs/concepts/architecture/control-plane-node-communication/#konnectivity-service).
