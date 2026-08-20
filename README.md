# Wonderbrass – Website

[![Build & Deploy nach GitHub Pages](https://github.com/wonderbrass/wonderbrass-blechsound.de/actions/workflows/pages.yml/badge.svg)](https://github.com/wonderbrass/wonderbrass-blechsound.de/actions/workflows/pages.yml)

Quellcode der offiziellen Website von [Wonderbrass](https://wonderbrass.github.io/wonderbrass-blechsound.de/) – Blechbläser-Combo mit Terminen, Bandmitgliedern, Sponsoren und Impressum.

## Tech-Stack

- [Jekyll](https://jekyllrb.com) 4.3 (Ruby, statischer Seitengenerator)
- [Bootstrap](https://getbootstrap.com) 5 und [Font Awesome](https://fontawesome.com) 6 (Icons) als Ruby-Gems eingebunden (siehe [_plugins/](_plugins)), keine vendorten CSS-Dateien und kein CDN-Aufruf zu Drittanbietern
- Kein eigenes JavaScript – nur das Bootstrap-JS-Bundle (Navigation/Collapse) ist eingebunden

### Farben

| Rolle       | Hex       | Verwendung                          |
|-------------|-----------|--------------------------------------|
| Primär      | `#B0892D` | Buttons, Akzente, Überschriften-Linie |
| Sekundär    | `#252525` | Fließtext, Navigation, Footer         |
| Tertiär     | `#C4C4C4` | Trennlinien, dezente Flächen          |

Definiert in `_sass/_variables.scss` – dort auch die Bootstrap-Farb-Map
(`$theme-colors`), damit z.&nbsp;B. `btn-primary` automatisch in Gold erscheint.

## Lokale Entwicklung

Voraussetzung: Ruby >= 3.1 und Bundler.

```bash
bundle install             # Gems installieren
bundle exec jekyll serve   # Dev-Server mit Live-Rebuild unter http://127.0.0.1:4000/wonderbrass-blechsound.de/
bundle exec jekyll build   # Statische Seite nach _site/ bauen
```

Es gibt keine Tests oder Linter in diesem Repo.

## Struktur

- `index.html`, `ueber-uns.html`, `termine.html`, `sponsoren.html`, `impressum.html` – die Seiten der Website
- `_layouts/`, `_includes/` – gemeinsames Seitengerüst (Header, Footer, Sponsor-Karte)
- `_data/` – listenartiger Inhalt (Bandmitglieder, Anlässe, Sponsoren, Termine), wird per `{% for %}`-Schleife eingebunden
- `_sass/`, `assets/css/main.scss` – Styling (Bootstrap + eigene Anpassungen)
- `_config.yml` – Site-Einstellungen inkl. Bandkontakt (`contact.*`) und Theme-Color
- `script/fetch_termine.rb` – holt die Konzerttermine von der Konzertmeister-API (siehe unten)

Mehr Architektur-Details (inkl. einiger nicht offensichtlicher Stolperfallen) stehen in [CLAUDE.md](CLAUDE.md).

## Konzertmeister-API (Termine)

Die Termine werden nicht manuell gepflegt, sondern bei jedem Build von
[Konzertmeister](https://konzertmeister.app) über `script/fetch_termine.rb`
abgerufen. Übernommen werden nur Termine vom Typ *Performance*, mit Status
*aktiv* und die von der Band explizit für die öffentliche Website
freigegeben wurden (`publicsite: true` in Konzertmeister). Das Script
schreibt zwei Dateien:

- `_data/termine.yml` – alle kommenden Termine.
- `_data/termine_vergangen.yml` – bereits stattgefundene Termine des
  laufenden Kalenderjahres (ab 1. Januar), neueste zuerst.

**API-Key erstellen:** In der [Konzertmeister-Web-App](https://web.konzertmeister.app)
unter den Organisationseinstellungen einen API-Key für die M2M-Schnittstelle
anlegen.

**API-Key sicher hinterlegen:** Ein Konzertmeister-API-Key darf **niemals**
im Repository landen (GitHub Pages ist immer öffentlich erreichbar, egal ob
das Repo privat oder öffentlich ist). Stattdessen als **verschlüsseltes
Repository-Secret** hinterlegen:

Settings → Secrets and variables → Actions → *New repository secret* →
Name `KONZERTMEISTER_API_KEY`, Wert der API-Key.

Der Workflow ([`.github/workflows/pages.yml`](.github/workflows/pages.yml))
reicht das Secret nur während des Build-Jobs als Umgebungsvariable an das
Fetch-Script durch – der Key landet nie im ausgelieferten `_site`-Verzeichnis
und ist für Website-Besucher:innen nicht einsehbar.

**Lokal mit echten Daten arbeiten** (optional): Key nur für den einen
Aufruf als Umgebungsvariable setzen, nicht dauerhaft exportieren:

```bash
KONZERTMEISTER_API_KEY="dein-key" bundle exec ruby script/fetch_termine.rb
```

Ohne gesetzten Key bleiben die zuletzt im Repo vorhandenen
`_data/termine*.yml` unverändert – lokales Entwickeln funktioniert also auch
ohne Key.

## Deployment

Die Website liegt auf [GitHub Pages](https://pages.github.com) als Projektseite unter `https://wonderbrass.github.io/wonderbrass-blechsound.de/` (kein eigenes Domain-Setup).

Workflow: Alle Änderungen laufen über den `develop`-Branch. Sobald `develop` nach `main` gemerged/gepusht wird, laufen automatisch zwei GitHub-Actions-Workflows:

- [`.github/workflows/pages.yml`](.github/workflows/pages.yml) baut die Seite und deployed sie auf GitHub Pages. GitHub Pages' eigener Safe-Mode-Build erlaubt keine zusätzlichen Gems wie `bootstrap`/`font-awesome-sass` oder eigene `_plugins` – deshalb baut der Workflow die Seite selbst per `bundle exec jekyll build`. Er läuft zusätzlich täglich per `schedule`, damit neue/geänderte Konzertmeister-Termine auch ohne Code-Änderung erscheinen.
- [`.github/workflows/release.yml`](.github/workflows/release.yml) erstellt automatisch ein neues [Release](https://github.com/wonderbrass/wonderbrass-blechsound.de/releases) nach dem Schema `YYYY.MM.VERSION` (z.&nbsp;B. `2026.08.1`).

**Einmalig im Repository einrichten:** Settings → Pages → *Build and deployment* → Source auf **„GitHub Actions"** stellen.
