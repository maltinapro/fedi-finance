# E02 – Identity, Login, SSO, Rollen & Rechte

**Phase:** 0 · **Abhängig von:** E01 · **Status:** offen

## Ziel
Sichere Anmeldung über Keycloak (OIDC) mit SSO-Anbindung verschiedener Anbieter sowie ein Rollen-/Rechtemodell für Buchhaltungsprozesse.

## Kontext / Links
[architecture.md](../architecture.md), [compliance.md](../compliance.md)

## Definition of Done
- Login per Keycloak (Authorization Code + PKCE), Backend validiert JWTs, Rollen werden durchgesetzt.
- Mindestens ein externer IdP (z. B. Google/Microsoft/GitHub oder generisches OIDC/SAML) konfigurierbar.

## Issues
- [ ] **E02-01 Keycloak-Topologie entscheiden** – Realm je Mandant vs. eigener Keycloak je Mandant. AK: ADR in decisions.md.
- [ ] **E02-02 Keycloak-Konfiguration als Code** – Realm-Import/`keycloak-config-cli`/Terraform, Clients (Frontend, Backend), Rollen. AK: Realm reproduzierbar erstellbar.
- [ ] **E02-03 Backend-Authentifizierung** – JWT-Validierung (JWKS), Claims → Benutzerkontext, Mandantenbindung. AK: Tests mit ungültigen/abgelaufenen Tokens.
- [ ] **E02-04 Rollenmodell** – Rollen: Inhaber/Admin, Buchhalter, Sachbearbeiter, Leser, Steuerberater (extern), Betriebsprüfer (read-only, zeitlich begrenzt), KI-Dienstkonto. AK: Matrix in docs.
- [ ] **E02-05 Autorisierung (RBAC + Ressourcen)** – Policy-Schicht im Backend (Permission-Checks je Use-Case), Tests je Rolle. AK: Matrix automatisiert getestet.
- [ ] **E02-06 SSO-/IdP-Anbindung** – Identity Brokering, Mapping von Gruppen/Rollen, Anleitung. AK: Mindestens ein externer IdP getestet.
- [ ] **E02-07 MFA & Passwort-Richtlinien** – TOTP/WebAuthn, Brute-Force-Schutz, Session-Timeouts. AK: Konfiguration dokumentiert.
- [ ] **E02-08 Benutzerverwaltung** – Benutzer einladen, Rollen zuweisen, deaktivieren (UI + API über Keycloak Admin API). AK: Audit-Log-Einträge.
- [ ] **E02-09 Service-zu-Service-Auth** – Backend ↔ AI-Gateway ↔ PDFCraft (mTLS oder signierte Tokens). AK: Konzept + Implementierung.

## Offene Fragen
Siehe decisions.md Nr. 6.
