# Storage: S3 für die Anwendung, Rook-Ceph im Cluster

> Arbeitsstand, kein Rechtsrat. Die Aussagen zu GoBD und DSGVO vor Produktivstart von der Steuer-/Rechtsberatung prüfen lassen
> (siehe [compliance.md](compliance.md#technische-umsetzung-der-unveränderbarkeit-dokumentenarchiv)).

Dieses Dokument bündelt die Entscheidungen zum Storage (Stand 11/2026). Die **Anwendung kennt nur S3**: Sie spricht die S3-API
und weiß nichts von Ceph, Rook oder PVCs für Dokumente. Welche Software den S3-Dienst bereitstellt, ist Betreiber-Sache
(im Zielcluster Rook-Ceph RGW, in der Dev-Umgebung SeaweedFS, in Tests jeder S3-Server mit Object Lock). Der Start erfolgt
mit **mindestens drei Nodes**.

## 1. Entscheidungen im Überblick

| # | Entscheidung |
| --- | --- |
| S1 | **Dokumente liegen ausschließlich in S3**, nie in der Datenbank und nicht auf PVCs. Die DB hält nur Metadaten (Hash, Key, Zeitstempel, Frist). Es gibt kein PVC-Backend für Dokumente. |
| S2 | **Zwei Buckets je Mandant:** `data` für aktuelle/Arbeitsdaten (veränderlich, löschbar) und `archive` für freigegebene Belege (Object Lock, unveränderbar). |
| S3 | Die Anwendung ist **S3-Provider-neutral** (Endpoint, Region, Bucketnamen, Zugangsdaten per Konfiguration; Path-Style einstellbar). Voraussetzung an den Provider: Versioning und Object Lock (Compliance und Governance) für den Archiv-Bucket. |
| S4 | **Zugangsdaten** je Bucket als Kubernetes-Secret im Mandanten-Namespace, bereitgestellt von einem Operator/Provisioner, nicht vom Helm-Chart und nicht von Hand. Im Zielcluster: Rook `ObjectBucketClaim` für `data`, Provisioner-Job für `archive`. |
| S5 | Object-Lock-Modus im Archiv: **Compliance** in Produktion, **Governance** in Dev/Test (Helm-Wert); Retention wird erst bei der Freigabe gesetzt und läuft bis Fristende. |
| S6 | Buckets gehören nicht zum Helm-Release-Lebenszyklus; der Archiv-Bucket überlebt das Offboarding bis Fristende. |
| S7 | **Rook-Ceph** ist der Cluster-Storage (Open Source, LGPL): RBD für PVCs (Postgres u. a.), RGW für S3. Start mit 3 Nodes. Das ist reine Infrastruktur ([Abschnitt 6](#6-cluster-storage-rook-ceph)). |
| S8 | **Offsite-Backup ist Pflicht:** Velero (`snapshotMoveData`), Barman und Archiv-Replikator schreiben in ein S3-Ziel mit Object Lock an einem anderen Standort (Referenz: SeaweedFS), EU, verschlüsselt. Ceph ist kein Backup. |

## 2. S3-Vertrag der Anwendung

Konfiguration des Backends (Umgebungsvariablen, vom Helm-Chart gesetzt; Werte unter `s3.*`):

| Einstellung | Bedeutung |
| --- | --- |
| `S3_ENDPOINT`, `S3_REGION`, `S3_FORCE_PATH_STYLE` | Endpoint des S3-Dienstes (im Cluster intern, z. B. RGW-Service), Region (bei Ceph/SeaweedFS beliebig, z. B. `us-east-1`), Path-Style (bei Ceph/SeaweedFS `true`) |
| `S3_CA_BUNDLE` (optional) | CA für interne TLS-Zertifikate |
| `S3_DATA_BUCKET`, `S3_ARCHIVE_BUCKET` | Bucketnamen (aus der Bucket-ConfigMap/dem Provisioning) |
| Zugangsdaten `data` / `archive` | je Bucket ein eigenes Secret mit `AWS_ACCESS_KEY_ID` und `AWS_SECRET_ACCESS_KEY` (Format von Rook-OBC); als Env oder Datei gemountet, nie im Image oder im Repo |
| `S3_ARCHIVE_OBJECT_LOCK_MODE` | `COMPLIANCE` (Produktion) oder `GOVERNANCE` (Dev/Test) |

Chart-Werte (E12-04): `s3.endpoint`, `s3.region`, `s3.forcePathStyle`, `s3.data.{bucket,existingSecret}`,
`s3.archive.{bucket,existingSecret,objectLockMode}`. Das Chart verwendet immer `existingSecret`/ConfigMap-Verweise; wie diese
entstehen (Operator, External Secrets, Handarbeit in Dev), ist dem Chart egal.

- **Startup-Prüfung:** Das Backend prüft beim Start, ob beide Buckets erreichbar sind und der Archiv-Bucket Versioning und Object Lock aktiv hat. Sonst startet es nicht (im Dev-Modus nur Warnung).
- **Storage-Abstraktion** im Backend (E08-01) mit zwei Rollen, `DataStore` und `ArchiveStore`; der `ArchiveStore` bietet nur „anlegen“ und „lesen“, keinen Code-Pfad zum Überschreiben oder Löschen.
- **Mandantentrennung:** Jeder Mandant hat eine eigene Instanz im eigenen Namespace mit eigenen Buckets und eigenen Zugangsdaten. Es gibt keine geteilten Buckets; die Trennung kommt aus Namespace, Buckets und Zugangsdaten, nicht aus Key-Präfixen.
- **Tests/Dev:** SeaweedFS in `deploy/dev/compose.yaml` unterstützt Object Lock (geprüft: Bucket mit Object Lock anlegen, Objekt mit `COMPLIANCE`-Retention ablegen, Löschen auch mit Bypass wird mit `AccessDenied` abgelehnt). Der vorab angelegte Bucket `fedifinance` dient als `data`-Bucket; Tests und der Dev-Init legen den Archiv-Bucket mit Object Lock selbst an (E08-01).

## 3. Bucket `data` (aktuelle Daten)

Für alles, was noch nicht oder nicht endgültig archiviert ist. Versioning aus, Löschen erlaubt, Lifecycle-Regeln räumen auf.

| Präfix | Inhalt | Aufbewahrung im Bucket |
| --- | --- | --- |
| `uploads/` | Hochgeladene Belege in Quarantäne bis Virenscan und Typprüfung bestanden sind (E08-02) | bis zur Übernahme ins Archiv, sonst 30 Tage |
| `previews/` | PDF-Vorschauen und Entwürfe aus PDFCraft (nicht GoBD-relevant, [pdfcraft.md](pdfcraft.md)) | 7 Tage |
| `exports/` | Kundenexporte (E13-04), Download per zeitlich begrenztem Link | 7 Tage |
| `tmp/` | Zwischenergebnisse (z. B. OCR, Import) | 1 Tag |
| `ai/` | Quelldokumente/Anhänge für die KI-Indexierung, wenn nicht aus dem Archiv gelesen (E14) | solange nötig, mandantenbezogen löschbar |

- Alles hier ist **ersetzbar oder reproduzierbar** und unterliegt nicht der Aufbewahrungspflicht; Löschwünsche (DSGVO) lassen sich sofort umsetzen.
- **Übergang zum Archiv:** Ein hochgeladener Beleg wird nach bestandener Prüfung unverändert (gleicher SHA-256) in den Archiv-Bucket geschrieben, anschließend wird die Quarantäne-Kopie gelöscht. Eingangsbelege müssen zeitnah archiviert werden (GoBD): Bis dahin gilt der `uploads/`-Stand als nicht archiviert; Fristen und Alarm bei zu langer Verweildauer in E08-02.
- Lifecycle-Regeln und Lösch-Rechte (kein Object Lock) sind der Grund für die Trennung: Im Archiv-Bucket lassen sich keine temporären Daten ablegen, ohne sie unlöschbar zu machen.
- Backup: nur `uploads/` (noch nicht archivierte Originale) wird offsite gesichert, der Rest ist flüchtig ([Abschnitt 8](#8-offsite-backup-und-archiv-replikat)).

## 4. Bucket `archive` (Object Lock)

- **Name** `<prefix>-<tenant>-archive`; Versioning und Object Lock werden **beim Anlegen des Buckets** aktiviert (nachträglich geht das nur eingeschränkt und provider-abhängig).
- **Keys** hash-adressiert: `sha256/<erste zwei Hex-Zeichen>/<sha256>`; PDF, eingebettetes XML und Render-Snapshot sind
  getrennte Objekte. Gleicher Inhalt = gleicher Key (idempotent).
- **Retention** wird bei der Freigabe gesetzt (`PutObject` mit Mode und `RetainUntilDate`), nie bei Entwürfen oder Vorschauen
  (diese liegen im `data`-Bucket). `RetainUntilDate` = Ende der Aufbewahrungsfrist (Jahresende der Entstehung +
  Frist, [compliance.md](compliance.md#aufbewahrungsfristen-richtwerte-deutschland)) plus Sicherheitsreserve. Eine Retention
  kann nur verlängert, nie verkürzt werden (z. B. bei Fristverlängerung); für Prüfungen/Streitfälle ist ein **Legal Hold** möglich.
- **Modus:** Compliance (Produktion): auch Admins können vor Ablauf nicht löschen oder ändern. Governance (Dev/Test): nur mit
  besonderem Recht umgehbar, damit Testdaten wieder entfernt werden können. Helm-Wert `s3.archive.objectLockMode`.
- **Berechtigungen:** Die Archiv-Credentials erlauben nur `GetObject`, `PutObject`, `PutObjectRetention`, `GetObjectRetention`,
  `ListBucket` auf diesem Bucket: kein `DeleteObjectVersion`, kein `BypassGovernanceRetention`, keine Änderung der
  Bucket-/Object-Lock-Konfiguration (per Bucket-Policy bzw. Nutzerrechte des Providers).
- **Ablauf bei Freigabe:** Beleg rendern → Objekte mit Retention im Archiv ablegen → DB-Transaktion (Belegnummer, Metadaten) committen.
  Scheitert das Ablegen, wird zurückgerollt (keine Lücke). Scheitert der DB-Commit nach dem Ablegen, bleibt ein gesperrtes,
  aber unschädliches Waisenobjekt (hash-adressiert, wird bei erneuter Freigabe wiederverwendet); ein Job meldet Waisen.
- **Löschen:** Nach Fristende wird nicht automatisch gelöscht, sondern ein Löschvorschlag mit Freigabe erzeugt (E08-06, E11-03);
  erst danach darf der Lifecycle die Objektversionen entfernen.
- **Integrität:** periodischer Hash-Abgleich Objekt ↔ DB (E08-04), Hash-Kette (E08-05).
- **Ohne Object Lock** (Provider kann es nicht) ist das Archiv nur anwendungsseitig write-once und damit deutlich schwächer;
  das ist nur für Dev/Test erlaubt (Startup-Prüfung, siehe oben) und nicht für Produktion.

## 5. Zugangsdaten und Provisioning

Ziel: Niemand tippt Zugangsdaten ab. Der Provisioner legt Buckets und Benutzer an und schreibt die Zugangsdaten als Secret in den Mandanten-Namespace.

| Schritt | Werkzeug (Zielcluster mit Rook-Ceph) | Ergebnis im Namespace `tenant-<id>` |
| --- | --- | --- |
| `data`-Bucket | Rook **ObjectBucketClaim** (StorageClass mit `reclaimPolicy: Delete`) | Secret + ConfigMap mit gleichem Namen wie der Claim: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `BUCKET_HOST`, `BUCKET_PORT`, `BUCKET_NAME`, `BUCKET_REGION` |
| `archive`-Bucket | **Provisioner-Job** des Mandanten-Provisionings (E12-07): legt mit RGW-Admin-Zugang den Bucket **mit Object Lock und Versioning** an, einen RGW-User mit eingeschränkten Rechten (siehe Abschnitt 4) und schreibt das Secret | Secret `fedifinance-s3-archive` (gleiches Format), ConfigMap mit Bucketname |

- **Warum zwei Wege:** Der Rook-OBC kennt nach unserem Kenntnisstand kein Object Lock beim Anlegen des Buckets; das ist im Spike von E12-04 zu bestätigen. Kann OBC (oder künftig COSI) Object Lock, wird der Archiv-Bucket ebenfalls per OBC angelegt und der Provisioner-Job entfällt. Das Chart bleibt davon unberührt (S3-Vertrag).
- **Reclaim-Policy:** `data`-Bucket wird mit dem Claim gelöscht, der `archive`-Bucket **nie** automatisch (Object Lock verhindert es ohnehin, und das Provisioning legt ihn außerhalb des Release-Lebenszyklus an).
- **Provisioner-Zugang:** Die RGW-Admin-Zugangsdaten liegen nur im Namespace des Provisioners (Cluster-Basis, nicht im Mandanten-Namespace); der Job schreibt per ServiceAccount mit minimaler RBAC-Berechtigung nur das Zielsecret.
- **Rotation:** Zugangsdaten werden regelmäßig rotiert (Provisioner legt neuen Key an, schreibt das Secret, Pods werden neu gestartet, alter Key wird nach einer Übergangszeit gelöscht, E12-09).
- **Zugriff aus dem Mandanten:** NetworkPolicy erlaubt dem Backend nur den Weg zum S3-Endpoint; der Browser greift nie direkt auf S3 zu (Downloads über das Backend oder zeitlich begrenzte Links, E13-05).
- **Andere Umgebungen:** Dev: feste lokale Zugangsdaten aus `deploy/dev/.env`. Externer S3-Anbieter: Secret per External Secrets/Sealed Secrets (E12-09); der S3-Vertrag bleibt gleich.

## 6. Cluster-Storage (Rook-Ceph)

Reine Infrastruktur; die Anwendung hängt nicht davon ab (siehe Abschnitt 2).

### Topologie (3 Nodes)

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

### StorageClasses

| StorageClass | Backend | Zugriff | Verwendung |
| --- | --- | --- | --- |
| `fedifinance-block` (Standard) | Ceph RBD, `size 3` | RWO | PostgreSQL (CloudNativePG), Valkey, KI-Index, übrige PVCs; CSI-Snapshots für Velero |
| Object Store (RGW) | Ceph RGW, `size 3` | S3 | Buckets `data` und `archive` je Mandant |

CephFS (RWX) wird nur bei Bedarf eines Dienstes mit geteiltem Dateizugriff ergänzt; für Dokumente ist es nicht vorgesehen.
Quotas je Mandant: `ResourceQuota` für PVCs (E12-05) und RGW-User-/Bucket-Quota (Größe, Objektanzahl) je Bucket.

## 7. Mandanten-Offboarding und DSGVO

- Object Lock im Compliance-Modus ist nicht umkehrbar: Fehlerhaft abgelegte Belege und Löschwünsche nach DSGVO lassen sich vor
  Fristablauf nicht entfernen. Korrekturen erfolgen per Storno/Gutschrift (GoBD). Rechtsgrundlage für die Aufbewahrung statt
  Löschung: Art. 17 Abs. 3 lit. b DSGVO (rechtliche Verpflichtung) – prüfen lassen. Das Löschkonzept (E11-03) sperrt Daten
  und löscht nach Fristende; Datenkatalog und AVV weisen darauf hin. Der `data`-Bucket enthält keine aufbewahrungspflichtigen Daten und kann sofort geleert werden.
- Beim Offboarding (E12-10) erhält der Kunde den vollständigen Export (E13-04). Der `archive`-Bucket bleibt bis Fristende
  bestehen (S6); Namespace, `data`-Bucket und alle übrigen Daten werden nach Konzept gelöscht. Weil der Namespace entfällt, geht die
  Zugriffs-Verwaltung für das Archiv an den Betreiber (Provisioner-Secret im Betreiber-Namespace, Lesezugriff für Betriebsprüfungen über einen
  Export-Job). Der Vertrag muss regeln, wer die Aufbewahrung danach trägt (Kosten, Zugriff);
  Alternative: Kunde übernimmt das Archiv per Export und beendet die Aufbewahrung in eigener Verantwortung. Nach Fristende Bucket löschen.

## 8. Offsite-Backup und Archiv-Replikat

Details (Velero, Barman, Rhythmen, Aufbewahrung, RPO/RTO) stehen in [operations.md](operations.md#backup-und-restore); hier die Storage-Seite.

- **Offsite ist Pflicht.** Ein einzelner S3-/Ceph-Cluster (auch mit 3 Replikaten) schützt nicht vor Fehlbedienung, Softwarefehlern, Brand oder Ransomware. Das Ziel liegt an einem anderen Standort bzw. bei einem anderen Anbieter, in der EU, mit eigenen Zugangsdaten und Verschlüsselung.
- **Velero** nutzt `snapshotMoveData`: Der CSI-Snapshot der RBD-Volumes wird per Kopia zum Offsite-Ziel übertragen. Nur der Snapshot im selben Ceph-Cluster wäre kein Backup.
- **Ziel (Entscheidung):** S3 mit Object Lock und Versioning. Referenz: eigener SeaweedFS-Server (OSS, Object Lock getestet, siehe oben) an einem zweiten Standort; gleichwertig ein EU-S3-Dienst eines anderen Anbieters mit nachgewiesenem Object Lock. Ein zweiter Ceph-Cluster ist möglich, für den Start aber unverhältnismäßig. Garage unterstützt nach unserem Kenntnisstand kein Object Lock und scheidet aus; MinIO scheidet aus (AGPL, keine Community-Images mehr).
- **Archiv-Replikat:** Der Archiv-Replikator (CronJob des Backends) kopiert jedes Archivobjekt in den Offsite-Bucket des Mandanten, übernimmt Retention-Modus und -Datum, prüft den SHA-256 und meldet Rückstand als Metrik. RGW-Multisite wird bewusst nicht verwendet: Es braucht einen zweiten Ceph-Cluster und repliziert auch Fehler und Löschmarker. Der Replikator-User darf nur schreiben.
- **Bucket `data`:** Der Replikator sichert nur das Präfix `uploads/` (noch nicht archivierte Originale) in einen nicht gesperrten, versionierten Offsite-Bucket; `previews/`, `exports/`, `tmp/` sind reproduzierbar und werden nicht gesichert.
- **Wiederherstellung des Archivs** erfolgt aus dem Offsite-Bucket in einen neuen Archiv-Bucket mit Object Lock; Retention-Daten werden beim Zurückspielen erneut gesetzt (E13-06).
- Restore-Tests laufen regelmäßig automatisiert (E13-07), einschließlich Hash-Prüfung der Archivobjekte.

## Umsetzung in den Epics

| Epic | Inhalt |
| --- | --- |
| E08-01 | Storage-Abstraktion `DataStore`/`ArchiveStore` auf S3, Startup-Prüfung, Object-Lock-Tests |
| E08-02 | Upload in `data/uploads/`, Prüfung, Übernahme ins Archiv |
| E08-04 / E08-05 / E08-06 | Hash-Abgleich, Hash-Kette, Fristen und Löschsperre |
| E11-03 | Lösch-/Sperrkonzept mit nicht umkehrbarer Retention |
| E12-01 / E12-04 | Rook-Ceph in der Cluster-Basis, StorageClass/RGW, Chart-Werte `s3.*`, Quotas, Verschlüsselung |
| E12-07 / E12-09 / E12-10 | Provisioning von Buckets, Benutzern und Secrets (OBC + Provisioner-Job), Rotation, Offboarding mit bestehen bleibendem Archiv-Bucket |
| E13-01 / E13-02 / E13-03 | Offsite-Ziel mit Object Lock, Velero (`snapshotMoveData`), Barman |
| E13-11 | Archiv-Replikator |
| E17 | Ceph-Monitoring und -Alarme |
