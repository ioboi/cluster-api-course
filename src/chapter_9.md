# GitOps einrichten

## 🚀 Argo CD installieren

Argo CD bringt GitOps in dein Cluster. Du definierst den Soll-Zustand in Git – Argo CD sorgt für die Umsetzung.

Namespace erstellen und Argo CD installieren:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Warten bis alle Pods laufen:

```bash
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

## 🔑 Zugriff einrichten

Das Admin-Passwort aus dem Secret holen:

```bash
argocd_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Admin-Passwort: $argocd_password"
```

Port-Forward für den Zugriff:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Web-UI aufrufen: https://localhost:8080

- Username: `admin`
- Passwort: Das ausgegebene Admin-Passwort

## 📂 Git-Repository vorbereiten

Erstelle ein Git-Repository mit dieser Struktur:

```
git-repo/
├── clusters/
│   └── cluster.yaml
└── templates/
    └── cluster-template.yaml
```

**cluster.yaml** (Cluster-Definition):

```yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: my-gitops-cluster
  namespace: default
spec:
  # Deine Cluster-Konfiguration
```

**cluster-template.yaml** (Cluster-Template):

```yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: ClusterClass
metadata:
  name: my-cluster-template
  namespace: default
spec:
  # Deine Template-Konfiguration
```

### 🔐 Private Repository Authentication

Für private GitHub-Repositories erstelle ein Personal Access Token (PAT):

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token mit `repo` permissions
3. Token kopieren

Secret für Repository-Zugriff erstellen:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: https://github.com/dein-user/dein-repo
  password: dein-github-token
  username: dein-github-username
```

Secret anwenden:

```bash
kubectl apply -f repo-credentials.yaml
```

## 🔄 Application erstellen

Application für Cluster-Management:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-management
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/dein-user/dein-repo
    targetRevision: main
    path: clusters
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Diese Application überwacht den `clusters`-Ordner in deinem Git-Repository. Alle YAML-Manifeste in diesem Ordner werden automatisch auf das Management-Cluster angewendet.

Application für Cluster-Templates:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-templates
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/dein-user/dein-repo
    targetRevision: main
    path: templates
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Diese Application überwacht den `templates`-Ordner und stellt Cluster-Templates zur Verfügung.

Applications anwenden:

```bash
kubectl apply -f cluster-application.yaml
kubectl apply -f cluster-templates-application.yaml
```

## ✅ Synchronisation prüfen

Applications auflisten:

```bash
kubectl get applications -n argocd
```

Status in der Web-UI prüfen.

## 🎯 Das Ergebnis

GitOps läuft jetzt:

1. **Änderungen in Git** → Argo CD erkennt sie automatisch
2. **Argo CD synchronisiert** → Cluster-Zustand passt sich an
3. **Vollständige Nachverfolgung** → Jede Änderung ist dokumentiert

Du verwaltest jetzt Cluster deklarativ über Git – genau wie Code.
