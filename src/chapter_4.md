# Cluster API Provider Docker (CAPD)

[CAPD](https://github.com/kubernetes-sigs/cluster-api/tree/main/test/infrastructure/docker)
ist ein Infrastruktur-Provider für Cluster API. Er nutzt Docker-Container als Maschinen – perfekt für lokale Tests und Labs.

---

## 🚀 Initialisieren

```bash
# Cluster Topology aktivieren
export CLUSTER_TOPOLOGY=true

# CAPD installieren
clusterctl init --infrastructure docker
```

✅ clusterctl init ist idempotent:

- Erkennt vorhandene Komponenten
- Installiert oder aktualisiert bei Bedarf
- Verhindert Duplikate und Konflikte

## 🧩 Wichtige Custom Resources (CRDs) von CAPD

| CRD                       | Zweck                                                                 |
| :------------------------ | :-------------------------------------------------------------------- |
| DockerCluster             | Repräsentiert das Infrastruktur-Backend eines Clusters auf Docker     |
| DockerClusterTemplate     | Vorlage für DockerCluster, nützlich bei Cluster-Templates             |
| DockerMachine             | Einzelne virtuelle Maschine (Control Plane oder Worker) als Container |
| DockerMachineTemplate     | Vorlage für DockerMachine, etwa für skalierbare Gruppen               |
| DockerMachinePool         | Gruppe von Maschinen, die gemeinsam verwaltet werden                  |
| DockerMachinePoolTemplate | Vorlage für DockerMachinePool, für wiederverwendbare Definitionen     |

[Mehr Informationen zu den CRDs.](https://doc.crds.dev/github.com/kubernetes-sigs/cluster-api)
