# Access the Control Plane

To access the control plane we first need to get the `kubeconfig`.
Because we are using CAPI the process is the same as in [Access the Cluster](../hello-capi/access-the-cluster.md).

To retrieve the `kubeconfig` file you can use:

```bash
kubectl get secret k0s-example-kubeconfig -o template='{{ .data.value | base64decode }}' > config-k0s-example
```

The `config-k0s-example` will look like this:

```yaml
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: "..."
      server: https://192.168.97.2:30443
    name: k0s-example-k0s
contexts:
  - context:
      cluster: k0s-example-k0s
      user: k0s-example-admin
    name: k0s-example-admin@k0s-example-k0s
current-context: k0s-example-admin@k0s-example-k0s
kind: Config
users:
  - name: k0s-example-admin
    user:
      client-certificate-data: "..."
      client-key-data: "..."
```

Note the port `30443`. This is the default port of the [`Service`](https://docs.k0smotron.io/stable/resource-reference/controlplane.cluster.x-k8s.io-v1beta1/#k0smotroncontrolplanespecservice).

## Access on Linux

To use the `kubeconfig` you can use:

```
$ kubectl --kubeconfig config-k0s-example get pods --all-namespaces

NAMESPACE     NAME                             READY   STATUS    RESTARTS   AGE
kube-system   coredns-55c758887c-6784f         0/1     Pending   0          113s
kube-system   metrics-server-df68c566c-srnhf   0/1     Pending   0          104s

```

It's ok that these pods are currently `Pending`.
We don't have a `Machine` yet, where they can run.

## Access on Other Operating Systems

If you want to access your control plane on macOS or Windows you will need to change the `server` in `config-k0s-example`:

```diff
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: "..."
-      server: https://192.168.97.2:30443
+      server: https://localhost:30443
    name: k0s-example-k0s
contexts:
  - context:
      cluster: k0s-example-k0s
      user: k0s-example-admin
    name: k0s-example-admin@k0s-example-k0s
current-context: k0s-example-admin@k0s-example-k0s
kind: Config
users:
  - name: k0s-example-admin
    user:
      client-certificate-data: "..."
      client-key-data: "..."
```
