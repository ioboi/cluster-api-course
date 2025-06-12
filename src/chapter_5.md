# Das erste Cluster

## 🔨 Manifeste anwenden

Nutze dieses Manifest, um ein Cluster mit einem Control-Plane-Node und einem Worker-Node zu erzeugen:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/cluster-api/main/test/infrastructure/docker/examples/simple-cluster.yaml
```

> 📄 Alternativ: Datei lokal speichern als simple-cluster.yaml
> und mit `kubectl apply -f simple-cluster.yaml` anwenden.

## 🧭 Cluster-Ressourcen im Überblick

Das Manifest erzeugt:

- ein Cluster namens my-cluster
- ein DockerCluster als Infrastruktur-Backend
- ein KubeadmControlPlane mit 1 Control-Plane-Node
- zwei DockerMachineTemplate (für Control-Plane und Worker)
- ein MachineDeployment mit 1 Worker-Node
- ein KubeadmConfigTemplate für den Worker-Join

## 👁️ Status beobachten

```bash
kubectl get cluster
kubectl get kubeadmcontrolplanes
kubectl get machinedeployments
kubectl get machines
```

## 🐳 Was geschieht im Hintergrund

CAPD erzeugt neue Docker-Container,  
basierend auf den Ressourcen, die wir per `kubectl apply` erstellen.

Für jede `DockerMachine`, die erzeugt wird, startet CAPD einen neuen Container.  
Diese Container simulieren eine virtuelle Node mit systemd und Docker.  
Sie werden über `kubeadm` initialisiert oder gejoined.

Die laufenden Maschinen erscheinen als Docker-Container:

```bash
docker ps
```

[Mehr Informationen: "Cluster API CAPD Deep Dive 2021-03-25".](https://www.youtube.com/watch?v=67kEp471MPk)

## 🔍 Wenn es nicht klappt

````bash
# Prüfe die Controller-Logs
kubectl logs -n capi-system deployment/capi-controller-manager

# Schaue dir die Events an
kubectl get events --sort-by='.lastTimestamp'

# Status der Maschinen prüfen
kubectl describe machines

# DockerMachine-Details anschauen
kubectl describe dockermachines
```

## 🧼 Optional: Cluster löschen

```bash
kubectl delete cluster my-cluster
````
