# The Scenario

You work as a Platform Engineer at **Acme Cooperation**.
**Acme Cooperation** is specialized at developing custom software products.
At the moment new versions of these products are getting released by hand.

In den letzten Jahren hatten die Kunden der **Acme Cooperation** immer mehr Anforderungen an ihre Software, weshalb nun täglich neue Versionen ausgerollt werden.
Damit so viele Versionen veröffentlicht werden können, wurde vor ein paar Jahren [Kubernetes](https://kubernetes.io/) als Container Orchestrator eingeführt.

Mit der Einführung von Kubernetes wurden leider die Software-Entwicklungsprozesse etwas komplexer.
Die Entwickler:innen möchten nun Kubernetes Cluster als ein internes Software as a Service (SaaS) selbständig beziehen --- aber sie wollen sich nicht um den Betrieb kümmern müssen.

Deine Aufgabe ist nun, ein solches SaaS zu entwickeln.

Nach dem Sammeln von Anforderungen konntest du diese auf drei herunterbrechen:

- **GitOps-Workflow** Kubernetes Cluster werden in Git Repositories konfiguriert.
- **Automatische Bereitstellung** Keine manuellen Eingriffe bei Erstellung und Betrieb
- **Hosted control plane** Die Kubernetes Control-Plane wird durch ein zentrales Kubernetes Cluster bereitgestellt.
