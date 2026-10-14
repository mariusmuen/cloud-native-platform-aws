# ADR 0001: AWS-Zugang über IAM-Nutzer mit MFA und `aws login` statt IAM Identity Center

- **Datum:** 2026-10-14
- **Status:** Accepted

## Kontext

Für die tägliche Arbeit (Konsole, CLI, Terraform) wird eine Identität mit Adminrechten gebraucht – nicht Root, und ohne dauerhafte Access Keys auf dem Rechner (NF-01).
Best Practice wäre IAM Identity Center (SSO). Das setzt aber AWS Organizations voraus. Das Konto läuft im **Free Plan** mit ca. 158 USD Guthaben (gültig bis 04.05.2027). Der Beitritt zu bzw. das Anlegen einer Organization beendet das Guthaben sofort.

## Optionen

1. **IAM Identity Center + Organizations** – Best Practice, kurzlebige Credentials, aber Verlust des gesamten Guthabens.
2. **IAM-Nutzer mit Access Keys** – einfach, aber dauerhafte Schlüssel auf der Platte; Risiko bei Leak (z. B. versehentlicher Commit).
3. **IAM-Nutzer mit MFA + `aws login`** – CLI holt sich über die Konsolen-Anmeldung temporäre Credentials, keine Access Keys.

## Entscheidung

Option 3. Nutzer `marius-admin` in der Gruppe `admins` (Policy `AdministratorAccess`), MFA aktiv, keine Access Keys. CLI-Anmeldung per `aws login`. Root ist mit MFA gesichert und wird nicht mehr genutzt.

## Konsequenzen

- ✅ Keine langlebigen Schlüssel; gestohlene Credentials verfallen nach kurzer Zeit.
- ✅ Guthaben bleibt erhalten und deckt voraussichtlich das gesamte Projekt.
- ✅ Rechte hängen an der Gruppe, nicht am Nutzer – erweiterbar.
- ⚠️ IAM-Nutzer sind ein Einzel-Konto-Muster; kein zentrales Identity-Management.
- ⚠️ `AdministratorAccess` ist bewusst breit, weil der Nutzer die gesamte Plattform aufbaut.

**In einer Firma** würde ich eine Multi-Account-Struktur mit AWS Organizations (getrennte Accounts für dev/staging/prod) und IAM Identity Center mit Anbindung an den bestehenden Identity Provider (z. B. Entra ID) nutzen, mit rollenbasierten Permission Sets statt pauschaler Adminrechte.
Maschinen-Identitäten (GitHub Actions, Pods) nutzen in diesem Projekt ohnehin Rollen mit temporären Credentials (OIDC, IRSA) – siehe spätere ADRs.
