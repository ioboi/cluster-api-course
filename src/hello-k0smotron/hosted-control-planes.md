# Hosted Control Planes

Before we start creating our own hosted control planes
let's peel back the curtain on Kubernetes-in-Kubernetes.

You may remember the Kubernetes cluster architecture:

![Kubernetes cluster components overview](https://kubernetes.io/images/docs/components-of-kubernetes.svg)

A Kubernetes clusters consists of a control plane and a set of workers.
The control plane components are:

| Control Plane Component                                                                                             | Task                                                                                                                           |
| :------------------------------------------------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------- |
| [API Server](https://kubernetes.io/docs/concepts/architecture/#kube-apiserver)                                      | The central component that serves the Kubernetes API. This is the only component interacting directly with etcd.               |
| [etcd](https://kubernetes.io/docs/concepts/architecture/#etcd)                                                      | Distributed key-value store. Central data store of a Kubernetes cluster.                                                       |
| [Scheduler](https://kubernetes.io/docs/concepts/architecture/#kube-scheduler)                                       | Schedules pods onto worker nodes.                                                                                              |
| [Controller Manager](https://kubernetes.io/docs/concepts/architecture/#kube-controller-manager)                     | Hosts the controllers of the core API resources.                                                                              |
| [Cloud Controller Manager (_optional_)](https://kubernetes.io/docs/concepts/architecture/#cloud-controller-manager) | Integrates the underlying cloud provider into the Kubernetes cluster. For example makes service `type: LoadBalancer` possible. |

The idea behind hosted control planes is to run these components as `Pod`s on another Kubernetes cluster.
This means we can leverage the Kubernetes cluster to
implement high availability and auto-healing functionalities
for our hosted control planes.

> [!NOTE]
> Traditionally control plane components are hosted
> via [_Static Pods_](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/),
> which means they are managed directly by a node's [Kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/).

Next let's take a look at how a hosted control plane can be implemented.
