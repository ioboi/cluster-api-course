# Architektur

## Der Kern der Cluster API

Cluster API nutzt **Custom Resource Definitions (CRDs)** und das **Controller Pattern** – wie Kubernetes selbst.

### 🔄 Reconciliation Loop - Wie bei Deployments

Du kennst es von Deployments:

- Du sagst: "Ich will 3 nginx-Pods"
- Kubernetes sorgt dafür: erstellt, überwacht, repariert

Genau so mit Clustern:

- Du sagst: "Ich will 1 Control-Plane, 3 Worker"
- CAPI sorgt dafür: erstellt, überwacht, repariert

**Der Ablauf:**

1. Du definierst Zielzustand in YAML
2. Controller erkennt Abweichungen
3. Controller bringt Realität in Einklang

→ Genau wie bei `Deployments`, aber für Cluster!

## 📐 Bausteine der Architektur

### 🧩 CRDs (Custom Resources)

- `Cluster`: Definiert einen Kubernetes-Cluster.
- `Machine`: Definiert einen Node.
- `MachineSet`, `MachineDeployment`: Wie ReplicaSets und Deployments – nur für Maschinen.
- `InfrastructureCluster`, `InfrastructureMachine`: Provider-spezifische Entsprechungen (z.B. EC2, Docker-Container).

### ⚙️ Controller

| Namespace                         | Deployment                                    | Beschreibung                                                                                          |
| :-------------------------------- | :-------------------------------------------- | :---------------------------------------------------------------------------------------------------- |
| capi-system                       | capi-controller-manager                       | Verarbeitet generische Cluster-Ressourcen wie `Cluster`, `Machine`, `MachineSet`, `MachineDeployment` |
| capi-kubeadm-bootstrap-system     | capi-kubeadm-bootstrap-controller-manager     | Erstellt und pflegt `KubeadmConfig`-Ressourcen für das Node-Bootstrapping                             |
| capi-kubeadm-control-plane-system | capi-kubeadm-control-plane-controller-manager | Steuert `KubeadmControlPlane` und verwaltet damit Control Plane Nodes                                 |

→ Jeder Controller ist zuständig für „seine“ CRD – und sorgt für Reconciliation.

## 🧪 Beispiel: Ein neues Cluster entsteht

1. Du schreibst YAML mit `Cluster`, `Machine`, `KubeadmConfig`, ...
2. Du wendest es mit `kubectl apply` an.
3. Die Controller beobachten die Ressourcen:
   - Der Infrastructure Controller erstellt z.B. eine VM.
   - Der Bootstrap Controller erzeugt ein cloud-init-Template.
   - Der Control Plane Controller installiert Kubernetes.
4. Der Cluster taucht auf.

## ⏮️ Rückblick: Klassisches Cluster-Management

| Problem                   | Früher                              | Mit Cluster API                               |
| :------------------------ | :---------------------------------- | :-------------------------------------------- |
| Kein Standard             | Jede/r machte es anders             | Einheitliche CRDs                             |
| Manuelle Arbeit           | Bash-Skripte, klickbare GUIs        | YAML + Git = automatisierbar                  |
| Schwer zu debuggen        | Intransparente Fehler, unklare Logs | Controller-Logs & Events in Kubernetes        |
| Kompliziertes Upgrade     | Viele manuelle Schritte             | Version definieren – Reconciliation übernimmt |
| Kein Lifecycle-Management | "Fire-and-forget"                   | Vollständiger Lifecycle integriert            |

## 🔧 Motivation: Warum überhaupt?

- Kubernetes hat **selbst ein starkes API-Modell**.
- Warum nicht auch Cluster mit YAML beschreiben?
- Infrastruktur **deklarativ** verwalten – mit denselben Tools.
- **Multi-Cluster** und **GitOps** ermöglichen.
- **Abstraktion von Cloud-Details**: AWS, Azure, vSphere, OpenStack, Docker – alles über CAPI steuerbar.

## 🗺️ Überblick: Wer macht was?

| Komponente         | Aufgabe                                                |
| :----------------- | :----------------------------------------------------- |
| `clusterctl`       | CLI für Init, Move, Upgrade, etc.                      |
| Management Cluster | Führt die Cluster API aus                              |
| Workload Cluster   | Wird von Management Cluster erzeugt und verwaltet      |
| Provider           | Bringt Infrastruktur-CRDs + Controller mit (z.B. CAPD) |
