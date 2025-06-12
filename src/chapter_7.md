# Architektur im Detail

## ⚙️ Recap: Controller

| Namespace                         | Deployment                                    | Beschreibung                                                                                          |
| :-------------------------------- | :-------------------------------------------- | :---------------------------------------------------------------------------------------------------- |
| capi-system                       | capi-controller-manager                       | Verarbeitet generische Cluster-Ressourcen wie `Cluster`, `Machine`, `MachineSet`, `MachineDeployment` |
| capi-kubeadm-bootstrap-system     | capi-kubeadm-bootstrap-controller-manager     | Erstellt und pflegt `KubeadmConfig`-Ressourcen für das Node-Bootstrapping                             |
| capi-kubeadm-control-plane-system | capi-kubeadm-control-plane-controller-manager | Steuert `KubeadmControlPlane` und verwaltet damit Control Plane Nodes                                 |

→ Jeder Controller ist zuständig für „seine“ CRD – und sorgt für Reconciliation.

## Control plane machines relationships

![Control plane machines relationships](https://cluster-api.sigs.k8s.io/images/kubeadm-control-plane-machines-resources.png)

[Quelle: CustomResourceDefinitions relationships](https://cluster-api.sigs.k8s.io/reference/api/crd-relationships)

## Worker machines relationships

![Worker machines relationships](https://cluster-api.sigs.k8s.io/images/worker-machines-resources.png)

[Quelle: CustomResourceDefinitions relationships](https://cluster-api.sigs.k8s.io/reference/api/crd-relationships)

## Provider contract

[Quelle: Provider contract.](https://cluster-api.sigs.k8s.io/developer/providers/contracts/overview)

### 🏗️ Infrastructure Provider Contract

- **Ziel:** Infrastruktur für Cluster und Machine-Objekte bereitstellen (z. B. VMs, Netzwerke).
- **Ressourcen & Anforderungen:**
  - **InfraCluster**
    - namespace-scoped
    - `TypeMeta`, `ObjectMeta`, `APIVersion`
    - Implementiert Cluster‑Infrastruktur & Endpoint‑Angabe falls nötig
  - **InfraMachine**
    - namespace-scoped
    - `TypeMeta`, `ObjectMeta`, `APIVersion`
    - Verknüpft mit BootstrapConfig & erstellt Machine‑Instanzen
  - _(InfraMachinePool: künftiger Support)_
  - **Labels:** `cluster.x‑k8s.io/<version>` auf allen CRDs für Versionskonversion

### 🚀 Bootstrap Provider Contract

- **Ziel:** Generierung von Init-/Join‑Daten (z. B. cloud‑init, kubeadm) für das Hochfahren von Nodes.
- **Ressourcen & Anforderungen:**
  - **BootstrapConfig** (& Template)
    - namespace-scoped
    - `TypeMeta`, `ObjectMeta`, `APIVersion`
    - **Spec:** enthält Bootstrap‑Spezifikation
    - **Status:**
      - `status.dataSecret`: Referenz zu Secret mit Bootstrap‑Daten
      - `status.initialized` oder `status.ready`: zeigt abgeschlossenen Boot‑Prozess
    - **Optional:**
      - `status.conditions`
      - `status.terminalFailures`
      - Pausierunterstützung, ClusterClass‑Templates, Sentinel‑Dateien, Node‑Taints
  - **Labels:** `cluster.x‑k8s.io/<version>` an CRDs

### ☸️ Control Plane Provider Contract

- **Ziel:** Steuerungsebene eines Kubernetes‑Clusters instanziieren (API‑Server, Controller, Scheduler, etcd).
- **Ressource:** **ControlPlane** (+ List, Template)
  - namespace‑scoped, mit `TypeMeta`, `ObjectMeta`, `APIVersion`
  - **Spec‑Felder (sofern implementiert):**
    - `spec.controlPlaneEndpoint` (Host/Port)
    - `spec.replicas` _(Pointer)_, samt:
      - `status.selector`
      - `status.replicas`
      - `status.readyReplicas`
      - `status.updatedReplicas`
      - `status.unavailableReplicas`
      - `scale`‑Subresource
    - `spec.version` und `status.version` für K8s‑Version
    - `spec.machineTemplate` mit optional:
      - `readinessGates`
      - `nodeDrainTimeout`
      - Metadaten für Control‑Plane‑Machines
  - **Status‑Felder:**
    - `status.initialized`, `status.ready` (Reconcile‑Trigger)
    - Bedingungen (`status.conditions`) – mindestens `Ready`, zukünftig `Available`
    - `status.externalManagedControlPlane` für externe CPs
  - **Zusätzlich:**
    - Verwaltung von Kubeconfig‑Secret im Namespace des Management Clusters
    - Zertifikat‑Management: Secrets mit Label `cluster.x‑k8s.io/cluster-name=<Cluster>`
    - Machines über `failureDomains` verteilen
    - Metadata‑Propagation von ControlPlane → Maschinen/Noden
    - Unterstützung von `minReadySeconds`, `UpToDate` etc. nach v1beta2
