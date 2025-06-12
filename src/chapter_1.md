# Was ist die Cluster API?

Die Cluster API (CAPI) ist ein Kubernetes-Projekt der SIG Cluster Lifecycle.  
Sie definiert **CRDs und Controller**, um **Kubernetes-Cluster selbst wie Kubernetes-Ressourcen zu verwalten**.

**Kernidee:**

> Ein Kubernetes-Cluster erzeugt und verwaltet andere Kubernetes-Cluster.  
> Alles läuft deklarativ über YAML.

---

## 🔍 Was macht die Cluster API?

| Funktion                     | Beschreibung                                         |
| ---------------------------- | ---------------------------------------------------- |
| Cluster erzeugen             | Deklarativ mit YAML                                  |
| Cluster ändern               | Automatisch durch Reconciliation                     |
| Cluster löschen              | Ebenfalls deklarativ – durch `kubectl delete`        |
| Nodes hinzufügen / entfernen | Über Machine-/MachineSet-Ressourcen                  |
| Infrastruktur abstrahieren   | Provider-Plugins (AWS, Azure, vSphere, Docker, etc.) |

## ❌ Was macht die Cluster API **nicht**?

- Sie **betreibt keine Cluster** im Sinne von Monitoring oder Logging.
- Sie **verpackt keine Workloads** – dafür gibt es ArgoCD, Helm etc.
- Sie ist **nicht zuständig für Cluster-Inhalte** (nur deren Hülle).
- Sie **ersetzt kein GitOps**, sondern arbeitet gut **mit** GitOps zusammen.

## 🔄 Vorher vs. Nachher - Ein Beispiel

### Früher: Neues Cluster für Staging

1. AWS-Konsole öffnen
2. EC2-Instanzen manuell erstellen
3. kubeadm auf jeder Maschine ausführen
4. Join-Befehle kopieren
5. 2 Stunden später: Cluster läuft (hoffentlich)

### Mit CAPI: Neues Cluster für Staging

1. YAML schreiben (5 Minuten)
2. `kubectl apply -f cluster.yaml`
3. 10 Minuten später: Cluster läuft

## 🧭 Warum gibt es die Cluster API?

Vor CAPI:

- Cluster wurden oft **per Skript oder manuell** erstellt.
- **Keine Standards**: Jeder Cloud-Anbieter kochte sein eigenes Süppchen.
- **Wartung war schwer**: Upgrades, Reparaturen, Lifecycle – alles manuell.

Mit CAPI:

- **Wiederholbar**: Infrastruktur als Code.
- **Deklarativ**: Was im YAML steht, wird Realität.
- **Standardisiert**: Einheitliche Schnittstelle für verschiedene Provider.
