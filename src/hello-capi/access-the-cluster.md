# Access the Cluster

To access our cluster we need to retrieve the `kubeconfig`.
CAPI will generate a `kubeconfig` for each cluster and save it as a secret inside the namespace of the cluster on our management cluster.
The name of the secret is in the format of `<cluster>-kubeconfig`.

To retrieve the `kubeconfig` file you can use:

```bash
kubectl get secret example-kubeconfig -o template='{{ .data.value | base64decode }}' > example-kubeconfig
```

The `example-kubeconfig` will look like this:

```yaml
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: "..."
      server: https://172.18.0.6:6443
    name: example
contexts:
  - context:
      cluster: example
      user: example-admin
    name: example-admin@example
current-context: example-admin@example
kind: Config
users:
  - name: example-admin
    user:
      client-certificate-data: "..."
      client-key-data: "..."
```

## Access from Linux

To use the `kubeconfig` you can either use:

```bash
kubectl --kubeconfig example-kubeconfig get nodes
```

Or you can set the `KUBECONFIG` environment variable:

```bash
KUBECONFIG="$(pwd)/example-kubeconfig" kubectl get nodes
```

## Access to the Cluster on Other Operating Systems

If you do not have access to a Linux machine you will need to change the cluster address to the address of the CAPI-created load balancer.
You can find the address using the following command:

```bash
docker inspect --format='https://localhost:{{(index .NetworkSettings.Ports "6443/tcp" 0).HostPort}}' example-lb
```

Replace the cluster address in `example-kubeconfig` with this value:

```diff
 apiVersion: v1
 clusters:
   - cluster:
       certificate-authority-data: "..."
-      server: https://172.18.0.6:6443
+      server: https://localhost:32774
```

Now you should be able to access your cluster from a non-Linux machine.

## Install Cilium

Now that we are able to access the cluster we can actually install a CNI and make it possible to schedule workloads on our cluster.

```bash
 KUBECONFIG=example-kubeconfig helm install cilium oci://quay.io/cilium/charts/cilium --version 1.18.7 --namespace kube-system
```

After the installation, our cluster should show `AVAILABLE: True`.

```bash
$ kubectl get cluster
NAME      CLUSTERCLASS   AVAILABLE   CP DESIRED   CP AVAILABLE   CP UP-TO-DATE   W DESIRED   W AVAILABLE   W UP-TO-DATE   PHASE         AGE   VERSION
example                  True        1            0              1               1           0             1              Provisioned   49m
```
