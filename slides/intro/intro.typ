#let accent = rgb("#326CE5")

#set document(
  author: "Yannik Dällenbach",
  title: "Cluster API Kurs Einführung",
)

#set page(
  width: 160mm,
  height: 90mm,
  number-align: bottom+right,
  numbering: (..numbers) => {
    let total = numbers.pos().at(1) - 1
    let num = numbers.pos().at(0)
    if num != 1 {
      text(size: 0.8em, numbering("1/1", num - 1, total))
    }
  },
)

#set text(font: "Helvetica", size: 14pt)
#show figure.caption: set text(size: 0.4em)

#show heading.where(level: 1): x => { 
  pagebreak(weak: true)
  x.body
}

#show raw.where(block: true): it => {
  show raw.line: l => {
    text(fill: gray)[#l.number]
    h(1em)
    l.body
  }
  set text(0.6em)
  it
}

#let title = (
  title: str, 
  subtitle: str,
  author: str,
  location: str
) => {
  set page(
    background: align(top, line(stroke: 1em+accent, length: 100%))
  )
  place(horizon+left)[
    #text(size: 1.8em, weight: "bold", title)
    #linebreak()
    #text(size: 1.5em, weight: "bold", subtitle)
  ]
  place(bottom)[
    #author
    #linebreak()
    #location
  ]
}

#title(
  title: "Cluster API",
  subtitle: "Einführung",
  author: "Yannik Dällenbach",
  location: "TBZ, 18.02.2025"
)

= Inhalt

#grid(
[
- Administratives und Ablauf
- Was ist die Cluster API?
- Grundlegende Konzepte
- Demo
],
  image("assets/kubernetes-cluster-logos_final.svg", width: 50%),
  columns: (1fr, 1fr),
  align: (start, horizon+center),
)

= Vorstellungsrunde

Bitte stellt euch kurz vor:

#text(size: 0.9em)[
  *Name* Yannik Dällenbach
  #linebreak()
  *Wo arbeitet ihr?* bespinian
  #linebreak()
  *Wieso Kubernetes/Cluster API?* Fan der Kubernetes Architektur
]

= Unterlagen

#align(center)[
  #image("assets/qr-repository.svg")
  #link("https://ioboi.github.io/cluster-api-course/")
]

= Ablauf

#grid(
  [
    == Tag 1

    - Einführung
    - Erstes eigenes Cluster
    
    *Ziel:* Grundlagen verstehen
  ],
  [
    == Tag 2

    - Cluster Lifecycle
    - Add-ons

    *Ziel:* Grundlagen festigen
  ],
  columns: (1fr, 1fr),
  gutter: 8pt,
)

= Motivation

Kubernetes ist komplex.

`kubeadm` automatisiert _nur_ das Bootstrappen eines Clusters.

---

Löst die Herausforderungen für die automatische Provision von Maschinen, VPC, Load Balancers, etc. wie auch Lifecycle-Management nicht.


= Was ist die Cluster API?


- Kubernetes-Projekt der SIG Cluster Lifecycle
- Definiert *CRDs und Controller* für Cluster-Management

---

*Kernidee:*

Ein Kubernetes-Cluster erzeugt andere Kubernetes-Cluster.
Alles läuft deklarativ über YAML.

= Reconiciliation Loop

#align(center+horizon)[
  #image("assets/reconciliation-loop.pdf", height: 80%)
]

= Management vs. Workload Cluster


*Management Cluster:*

- Cluster API
- Verwaltet Workload Cluster

*Workload Cluster:*

- Applikationen

= Was macht CAPI?

#table(
  columns: (auto, auto),
  inset: 8pt,
  table.header(
    [Funktion], [Beschreibung],
  ),
  [ *Cluster erzeugen* ], [ Deklarativ mit YAML ],
  [ *Cluster ändern* ], [ Durch _Reconiciliation_],
  [ *Cluster löschen* ], [ Durch `kubectl delete`],
  [ *Nodes verwalten* ], [ Über `Machine`-Ressourcen],
  [ *Infrastruktur abstrahieren* ], [ Provider für AWS, Azure, etc.],
)


= Was macht CAPI NICHT?


- Betreibt keine Cluster (Monitoring/Logging)
- Verpackt keine Workloads
- Verwaltet Cluster-Inhalte
- Ersetzt GitOps

*CAPI verwaltet nur die "Cluster-Hülle"*

= Recap Cluster Architecture

#align(center+horizon)[
  #image("assets/kubernetes-cluster-architecture.svg", height: 80%)
]

= CRDs Control Plane

#align(center+horizon)[
  #image("assets/kubeadm-control-plane-machines-resources.png", height: 80%)
]

= CRDs Worker Machines

#align(center+horizon)[
  #image("assets/worker-machines-resources.png", height: 80%)
]

// | CRD                       | Zweck                                  |
// | ------------------------- | -------------------------------------- |
// | **Cluster**               | Definiert einen Kubernetes-Cluster     |
// | **Machine**               | Definiert einen Node                   |
// | **MachineSet**            | Wie ReplicaSet für Maschinen           |
// | **MachineDeployment**     | Wie Deployment für Maschinen           |
// | **ControlPlane**          | Verwaltet Control-Plane-Maschinen      |
// | **BootstrapConfig**       | Konfiguration für Node-Setup           |
// | **InfrastructureCluster** | Provider-spezifisch (z.B. AWS, Docker) |
// | **InfrastructureMachine** | Provider-spezifische Maschine          |

= Demo

- Erzeuge ein Cluster
- Skaliere dieses Cluster
- Lösche das Cluster wieder

