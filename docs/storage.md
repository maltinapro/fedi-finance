# Storage: Rook-Ceph, Dokumentenarchiv, Backup-Ziel

> Arbeitsstand, kein Rechtsrat. Die Aussagen zu GoBD und DSGVO vor Produktivstart von der Steuer-/Rechtsberatung prüfen lassen
> (siehe [compliance.md](compliance.md#technische-umsetzung-der-unveränderbarkeit-dokumentenarchiv)).

Dieses Dokument bündelt die Entscheidungen zum Storage (Stand 11/2026). Der Betreiber kann beliebige Storage-Software im
Cluster installieren; der Start erfolgt mit **mindestens drei Nodes**.

## Entscheidungen im Überblick

| # | Entscheidung |
| --- | --- |
| S1 | **Rook-Ceph** als Cluster-Storage (Open Source, LGPL): RBD für PVCs, RGW (S3) für das Dokumentenarchiv. Start mit 3 Nodes. |
| S2 | PDFs, XML und Render-Snapshots liegen **nie in der Datenbank**, sondern als Objekte im Archiv-Bucket; die DB hält nur Metadaten. |
| S3 | Archiv = **S3-Bucket je Mandant mit Versioning und Object Lock**, hash-adressierte Keys. Fallback: PVC mit Write-once in der Anwendung (nur Dev/Test oder Mandanten ohne RGW). |
| S4 | Object-Lock-Modus: **Compliance** in Produktion, **Governance** in Dev/Test; per Helm-Wert wählbar. Retention wird erst bei der Freigabe gesetzt und läuft bis Fristende. |
| S5 | Das **Backup-Ziel liegt außerhalb des Ceph-Clusters** (anderer Standort/Fehlerbereich, EU) und muss für das Archiv-Replikat Object Lock unterstützen. Ceph ist kein Backup. |
| S6 | Buckets werden vom Provisioning angelegt und gehören nicht zum Helm-Release-Lebenszyklus (Offboarding löscht sie nicht vor Fristende). |

## 1. Cluster-Topologie (3 Nodes)

- Rook-Operator und `CephCluster` per Helm (Charts `rook-ceph`, `rook-ceph-cluster`) in der Cluster-Basis (E12-01); Versionen
  (Rook, Ceph) gepinnt, Upgrades gestaffelt.
- Je Node mindestens **eine dedizierte Rohplatte** (SSD/NVMe, kein RAID darunter, nicht die System-Platte) als OSD; 3 MON,
  2 MGR. Empfehlung: 10-GbE-Netz für den Storage-Verkehr, mindestens 4 GiB RAM je OSD zusätzlich zur Anwendungslast
  (hyperkonvergent: Anwendungs-Pods laufen auf denselben Nodes; Requests/Limits setzen, damit Ceph nicht verdrängt wird).
- Pools **replicated, `size: 3`, `min_size: 2`, Failure-Domain `host`**. Kein Erasure Coding (braucht mehr Hosts).
  Nutzbare Kapazität = Rohkapazität / 3; Auslastung unter 70 % halten (Alarm bei `nearfull`).
- Verhalten bei Ausfall: Fällt **ein** Node aus, bleibt der Cluster verfügbar (2 von 3 Replikaten, `HEALTH_WARN`), stellt die
  Replikation aber erst wieder her, wenn der Node zurückkehrt. Fallen **zwei** Nodes aus, steht der Storage. Mit dem ersten
  zahlenden Kunden bzw. bei Wachstum einen vierten Node einplanen (dann Selbstheilung nach Ausfall).
- Verschlüsselung im Ruhezustand: OSD-Verschlüsselung (`encryptedDevice: true`); TLS für RGW über den Ingress (cert-manager).
- Monitoring: Ceph-Metriken und Alarme (Health, `nearfull`, OSD down, Slow Ops) in der Cluster-Basis (E17).

## 2. StorageClasses

| StorageClass | Backend | Zugriff | Verwendung |
| --- | --- | --- | --- |
| `fedifinance-block` (Standard) | Ceph RBD, `size 3` | RWO | PostgreSQL (CloudNativePG), Valkey, KI-Index, übrige PVCs; CSI-Snapshots für Velero |
| `fedifinance-fs` (optional) | CephFS | RWX | nur wenn ein Dienst geteilten Dateizugriff braucht; Fallback-Archiv-PVC |
| Object Store (RGW) | Ceph RGW, `size 3` | S3 | Archiv-Buckets je Mandant |

Quotas je Mandant: `ResourceQuota` für PVCs (E12-05) und RGW-User-/Bucket-Quota (Größe, Objektanzahl).

## 3. Dokumentenarchiv (S3 mit Object Lock)

- **Bucket je Mandant** `fedifinance-archive-<tenant>`; Versioning und Object Lock werden **beim Anlegen** aktiviert. Das
  Provisioning (E12-07) legt den Bucket per S3-API an (Header `x-amz-bucket-object-lock-enabled`); ein `ObjectBucketClaim`
  setzt Object Lock nach unserem Kenntnisstand nicht, daher nicht darauf verlassen.
- **Keys** hash-adressiert: `sha256/<erste zwei Hex-Zeichen>/<sha256>`; PDF, eingebettetes XML und Render-Snapshot sind
  getrennte Objekte. Gleicher Inhalt = gleicher Key (idempotent).
- **Retention** wird bei der Freigabe gesetzt (`PutObject` mit Mode und `RetainUntilDate`), nie bei Entwürfen oder Vorschauen
  (diese werden gar nicht im Archiv abgelegt). `RetainUntilDate` = Ende der Aufbewahrungsfrist (Jahresende der Entstehung +
  Frist, [compliance.md](compliance.md#aufbewahrungsfristen-richtwerte-deutschland)) plus Sicherheitsreserve. Eine Retention
  kann nur verlängert, nie verkürzt werden (z. B. bei Fristverlängerung); für Prüfungen/Streitfälle ist ein **Legal Hold** möglich.
- **Modus:** Compliance (Produktion): auch Admins können vor Ablauf nicht löschen oder ändern. Governance (Dev/Test): nur mit
  besonderem Recht umgehbar, damit Testdaten wieder entfernt werden können. Helm-Wert `storage.archive.objectLockMode`.
- **Berechtigungen:** Pro Mandant ein eigener RGW-User, der nur auf den eigenen Bucket zugreift und nur `GetObject`,
  `PutObject`, `PutObjectRetention`, `GetObjectRetention`, `ListBucket` darf: kein `DeleteObjectVersion`, kein
  `BypassGovernanceRetention`, keine Änderung der Bucket-/Object-Lock-Konfiguration. Zugangsdaten als Kubernetes-Secret.
- **Ablauf bei Freigabe:** Beleg rendern → Objekte mit Retention ablegen → DB-Transaktion (Belegnummer, Metadaten) committen.
  Scheitert das Ablegen, wird zurückgerollt (keine Lücke). Scheitert der DB-Commit nach dem Ablegen, bleibt ein gesperrtes,
  aber unschädliches Waisenobjekt (hash-adressiert, wird bei erneuter Freigabe wiederverwendet); ein Job meldet Waisen im Audit-Log.
- **Löschen:** Nach Fristende wird nicht automatisch gelöscht, sondern ein Löschvorschlag mit Freigabe erzeugt (E08-07);
  erst danach darf der Lifecycle die Objektversionen entfernen.
- **Integrität:** periodischer Hash-Abgleich Objekt ↔ DB (E08-04), Hash-Kette im Audit-Log (E08-05).
- **Fallback PVC:** Hash-adressierte Dateien auf RBD/CephFS, Write-once nur in der Anwendung (kein Code-Pfad zum Ändern/Löschen).
  Das ist die schwächere Maßnahme (Admins können Dateien ändern); sie ist in der Verfahrensdokumentation (E08-08) so zu
  beschreiben und nur für Dev/Test oder Mandanten ohne RGW zu verwenden. Das Backend nutzt eine Storage-Abstraktion mit beiden Backends (E08-01).
- **Dev-Umgebung:** Der S3-Dienst in `deploy/dev/compose.yaml` (SeaweedFS) unterstützt Object Lock; geprüft: Bucket mit
  Object Lock anlegen, Objekt mit `COMPLIANCE`-Retention ablegen, Löschen (auch mit Bypass) wird mit `AccessDenied` abgelehnt.
  Der vorab angelegte Bucket `fedifinance` hat kein Object Lock; Tests für E08-01 legen einen eigenen Bucket mit Object Lock an.

## 4. Mandanten-Offboarding und DSGVO

- Object Lock im Compliance-Modus ist nicht umkehrbar: Fehlerhaft abgelegte Belege und Löschwünsche nach DSGVO lassen sich vor
  Fristablauf nicht entfernen. Korrekturen erfolgen per Storno/Gutschrift (GoBD). Rechtsgrundlage für die Aufbewahrung statt
  Löschung: Art. 17 Abs. 3 lit. b DSGVO (rechtliche Verpflichtung) – prüfen lassen. Das Löschkonzept (E11-03) sperrt Daten
  und löscht nach Fristende; Datenkatalog und AVV weisen darauf hin.
- Beim Offboarding (E12-10) erhält der Kunde den vollständigen Export (E13-04). Die Archiv-Buckets bleiben bis Fristende
  bestehen (S6: Bucket-Lebenszyklus außerhalb von Helm, `helm.sh/resource-policy: keep` für zugehörige Objekte); der
  Namespace und alle übrigen Daten werden nach Konzept gelöscht. Der Vertrag muss regeln, wer die Aufbewahrung danach trägt
  (Kosten, Zugriff für Betriebsprüfungen); Alternative: Kunde übernimmt das Archiv per Export und beendet die Aufbewahrung
  in eigener Verantwortung. Nach Fristende Bucket löschen.

## 5. Backup-Ziel und Replikation

- **Getrennter Fehlerbereich:** anderer Standort oder Anbieter in der EU, eigene Zugangsdaten, verschlüsselt. Ein einzelner
  Ceph-Cluster schützt nicht vor Fehlbedienung, Softwarefehlern, Brand oder Ransomware.
- **Velero** (Kopia, CSI-Snapshots von RBD-PVCs) und **CloudNativePG/Barman** (WAL, PITR) schreiben auf dieses Ziel.
- **Archiv-Replikat:** Ein Job repliziert Archiv-Objekte (RGW-Multisite oder geplante Replikation) in einen Bucket des
  Backup-Ziels **mit Object Lock** und prüft nach dem Kopieren den SHA-256. Das Ziel muss daher Object Lock unterstützen:
  Kandidaten sind ein zweiter (kleiner) Ceph-Cluster oder SeaweedFS (Object Lock getestet, siehe oben); Garage unterstützt
  nach unserem Kenntnisstand kein Object Lock und ist für das Archiv-Replikat nicht geeignet. Endgültige Wahl und Test: E13-01.
- Restore-Tests regelmäßig automatisiert (E13-07), einschließlich Hash-Prüfung der Archivobjekte.

## Umsetzung in den Epics

| Epic | Inhalt |
| --- | --- |
| E08-01 | Storage-Abstraktion mit S3-Object-Lock-Backend und PVC-Fallback |
| E08-04 / E08-05 / E08-07 | Hash-Abgleich, Hash-Kette, Löschvorschlag nach Fristende |
| E11-03 | Lösch-/Sperrkonzept mit nicht umkehrbarer Retention |
| E12-01 / E12-04 | Rook-Ceph in der Cluster-Basis, StorageClasses, Quotas, Verschlüsselung |
| E12-07 / E12-10 | Provisioning von Bucket, RGW-User und Secret; Offboarding mit bestehen bleibenden Archiv-Buckets |
| E13-01 / E13-02 / E13-03 | Backup-Ziel mit Object Lock, Velero, Barman |
| E17 | Ceph-Monitoring und -Alarme |
