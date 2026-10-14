# DEVLOG

Pro Session drei Zeilen: **Erledigt · Gelernt · Hakt**. Neueste Einträge oben.

---

## 2026-10-14 · Woche 1 (vorgezogen) · Terraform-Grundlagen

- **Erledigt:** Übung mit S3-Bucket: Provider, Variable, Data Source (`aws_caller_identity`), Resource, Outputs; kompletter Lebenszyklus `init → fmt → validate → plan → apply → destroy`.
- **Gelernt:** Resource = anlegen und verwalten, Data Source = nur lesen. Argumente (Eingabe) vs. Attribute (Ausgabe, oft erst „known after apply“). Doku-Aufbau: Argument Reference vs. Attribute Reference. Der State verknüpft Code mit echten Ressourcen und enthält ggf. Secrets im Klartext. Nicht änderbare Eigenschaften (z. B. Bucket-Name) führen zu `-/+ replace` = löschen und neu anlegen → im Plan immer auf `to destroy` und `forces replacement` achten; Schutz über `prevent_destroy` und `moved`-Blöcke.
- **Hakt:** –

## 2026-10-14 · Woche 0 · AWS absichern + Repo

- **Erledigt:** Root-MFA geprüft; IAM-Gruppe `admins` + Nutzer `marius-admin` mit MFA, keine Access Keys; CLI-Anmeldung per `aws login` (temporäre Credentials), Region `eu-central-1`; AWS Budget mit Warnungen bei 11/27 USD (tatsächlich) und 27 USD (Prognose), Gutschriften ausgeschlossen; GitHub-CLI verbunden, Repo angelegt, Ordnerstruktur und `.gitignore`; Branch-Schutz für `main` per Ruleset (kein Löschen, kein Force-Push, Pull Request Pflicht); Online Boutique geforkt. **Woche 0 komplett.**
- **Gelernt:** Free-Plan-Konten verlieren ihr Guthaben, sobald sie AWS Organizations beitreten → kein IAM Identity Center (siehe [ADR 0001](docs/adr/0001-aws-access-iam-user.md)). Budgets müssen Gutschriften ausschließen, sonst warnen sie nie. Rechte über Gruppen statt direkt am Nutzer (wie AGDLP im AD). Historie auf geteilten Branches nie umschreiben; bei geleakten Secrets zuerst rotieren, nicht nur die Historie bereinigen.
- **Hakt:** Free Plan endet am 04.11.2026 → vorher auf Paid Plan wechseln (Guthaben bleibt bis 04.05.2027).

## 2026-10-13 · Woche 0 · Arbeitsumgebung

- **Erledigt:** WSL2 + Ubuntu 26.04, Docker Engine nativ in Ubuntu (statt Docker Desktop), AWS CLI, Terraform, kubectl, Helm, kind, k9s, tflint, gh installiert. Erster lokaler Cluster mit kind.
- **Gelernt:** Rollen von Terraform (Infrastruktur), Kubernetes (Betrieb der Container), Helm (Paketierung), Docker (Images bauen). Kubernetes gleicht Soll und Ist dauerhaft ab: gelöschter Pod wird sofort ersetzt. Auf EKS ist ein Node eine EC2-Instanz, Pods laufen über containerd – Docker nur zum Bauen.
- **Hakt:** –

---

## Fehler-Logbuch

Echte Fehler mit Symptom → Ursache → Lösung. Grundlage für Postmortem und Interview-Geschichten.

| Datum | Symptom | Ursache | Lösung | Lehre |
|---|---|---|---|---|
| 2026-10-14 | CLI-Standardregion war `us-east-1` statt `eu-central-1` | `aws login` übernimmt ohne Angabe die Default-Region | `aws configure set region eu-central-1` | Region immer explizit setzen; gemischte Regionen sind eine Hauptquelle für vergessene Ressourcen |
| 2026-10-14 | `terraform validate`: *Reference to undeclared input variable* / *undeclared resource* | `var.value` statt Data-Source-Referenz; Output aus Doku-Beispiel (`aws_instance.web`) übernommen | Referenzen auf eigene Blöcke angepasst | Werte kommen nur aus `var.*`, `data.*` oder Resources; Doku-Beispiele immer an eigenen Code anpassen |
| 2026-10-14 | git-E-Mail war der Platzhalter-Text | Befehl mit Platzhalter kopiert, ohne ihn zu ersetzen | `git config --global user.email` mit noreply-Adresse | Vor dem ersten Commit `git config --list` prüfen |
