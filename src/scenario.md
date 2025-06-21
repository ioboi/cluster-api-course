# Szenario: Kubernetes Cluster Self-Service bei Acme Corporation

## 🏢 Die Ausgangslage

Du arbeitest als Platform Engineer bei der **Acme Corporation**. Das Unternehmen entwickelt verschiedene Anwendungen und hat bisher Kubernetes-Cluster manuell erstellt. Entwickler:innen warten oft tagelang auf Test-Cluster und sind dadurch blockiert.

### 🎯 Das Ziel

Die Entwicklungsabteilung möchte ein **Self-Service-Portal** für leichtgewichtige Entwicklungs-Cluster. Entwicklerinnen sollen per Pull-Request schnell eigene Test-Cluster anfordern können:

- **Feature-Tests**: Single-Node k0s-Cluster für schnelle Experimente
- **Proof-of-Concepts**: Isolierte Umgebungen für neue Ideen
- **Schulungen**: Cluster für interne Workshops

### 📋 Die Anforderungen

1. **GitOps-Workflow**: Cluster entstehen durch Git-Commits
2. **k0s Single-Node**: Leichtgewichtige, batteriebetriebene Cluster
3. **Automatische Bereitstellung**: Ohne manuelle Eingriffe
4. **Einfache Verwaltung**: Cluster können über Git gelöscht werden

## 🚀 Die Aufgabe

**Baue ein System, bei dem eine Entwickler:in durch einen Pull-Request ein funktionsfähiges k0s-Cluster erhält.**

### Schritt 1: Management Cluster erstellen

Richte das Management Cluster mit k0smotron und Docker Infrastructure Provider ein.

### Schritt 2: GitOps vorbereiten

Argo CD auf Management Cluster installieren und mit einem Git-Repository verbinden.

### Schritt 3: k0s-Template erstellen

Definiere eine ClusterClass-Ressource für k0s-Entwicklungs-Cluster:

- `k0s-dev`: Single-Node mit k0s
- Vorkonfiguriert mit Konnectivity, CoreDNS und Metrics
- Optimiert für minimalen Ressourcenverbrauch

### Schritt 4: Self-Service implementieren

Erstelle einen Workflow, bei dem Entwickler nur eine kleine YAML-Datei ins Git-Repository committen müssen.

### Schritt 5: Ende-zu-Ende testen

Simuliere den kompletten Prozess: Pull-Request → k0s-Cluster → Workload-Deployment.

## Ressourcen

- [Argo CD: Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Cluster API: Quick Start](https://cluster-api.sigs.k8s.io/user/quick-start)
- [k0smotron: Per-module installation for Cluster API](https://docs.k0smotron.io/stable/install/#per-module-installation-for-cluster-api)
- [Writing a ClusterClass](https://cluster-api.sigs.k8s.io/tasks/experimental-features/cluster-class/write-clusterclass)

---

_Die folgenden Lektionen zeigen dir Schritt für Schritt, wie du dieses System aufbaust. Du kannst aber gerne zuerst selbst experimentieren!_
