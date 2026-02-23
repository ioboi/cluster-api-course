# Hello k0smotron

In [Hello CAPI](../hello-capi/hello-capi.md) we created a Kubernetes cluster using `kubeadm`.
Each control plane and worker node got its own `Machine`, which was just a container.
With [k0smotron](https://docs.k0smotron.io/stable/) we will explore how we can build Kubernetes-in-Kubernetes.
This means we will use a hosted control plane (HCP) for our Kubernetes clusters.

In this section we will cover the basics of k0smotron and
build a Kubernetes cluster with a hosted control plane
using [k0s](https://k0sproject.io/) as our Kubernetes distribution.

> [!WARNING]
> Creating and accessing the hosted control plane works on all operating systems. However, due to how Docker networking works on Windows and macOS, adding worker nodes only works on Linux.
