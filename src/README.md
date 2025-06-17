# Cluster API Kurs

> Dieser Kurs basiert auf dem offiziellen [The Cluster API Book](https://cluster-api.sigs.k8s.io).

## 🗓️ Tag 1 – Grundlagen & Einstieg

### 🕗 08:10–09:45

- **Lektion 1**: Cluster API verstehen
  _Was ist die Cluster API? Warum gibt es sie? Was kann sie – und was nicht?_

- **Lektion 2**: Architektur & Motivation
  _Historie (kubeadm), Probleme klassischer Cluster-Verwaltung, Lifecycle-Vergleich_

---

### 🕥 10:15–11:50

- **Lektion 3**: Lokales Setup gemeinsam aufsetzen
  _Docker Desktop oder Podman, `kind`, `clusterctl` – Umgebung vorbereiten_

- **Lektion 4 (Teil 1)**: CAPD initialisieren
  _`clusterctl init` ausführen, erste Ressourcen prüfen_

---

### 🍽️ 13:15–14:50

- **Lektion 4 (Teil 2)**: Erstes Cluster erzeugen
  _Manifeste generieren oder anwenden, Reconciliation beobachten, Zugriff testen_

- **Lektion 5**: Workload deployen & kubeconfig nutzen
  _Mit kubectl auf das Cluster zugreifen, nginx oder ähnlich deployen_

---

### 🕒 15:10–17:35

- **Lektion 6**: Bausteine und Architektur im Detail
  _CRDs, Controller Pattern, Management vs. Workload Cluster, CAPD verstehen_

- **Offenes Lab & Q&A**  
  _Cluster nochmals erstellen, Debugging, erste Experimente – individuelle Unterstützung_

## 🗓️ Tag 2 – Cluster-Lifecycle, GitOps & Fortgeschrittenes

### 🕗 08:10–09:45

- **Lektion 6**: Cluster-Lifecycle steuern
  _Cluster skalieren, upgraden, retten – Reconcile Loops entwirren_

- **Lektion 7 (Teil 1)**: GitOps anschliessen
  _GitOps-Prinzip greifen, Setup mit FluxCD oder ArgoCD_

---

### 🕥 10:15–11:50

- **Lektion 7 (Teil 2)**: Cluster mit Git verwalten
  _Cluster aus Git lesen lassen – alles automatisch per Pull-Model_

---

### 🍽️ 13:15–14:50

- **Lektion 8**: Recap & Review  
  _Wiederholung der wichtigsten Bausteine: Architektur, CLI, Lifecycle, GitOps – Was macht CAPI besonders?_

---

### 🕒 15:10–17:35

- **Lektion 9**: Fallbeispiele & Szenarien
- **Abschluss und Ausblick**: Cluster API Operator, Community & Roadmap
