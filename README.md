# Wonderbrass – Website

Offizielle Website von Wonderbrass, umgesetzt mit **Jekyll** und
**Bootstrap als Sass-Version**, gehostet auf **GitHub Pages**.

## Farben

| Rolle       | Hex       | Verwendung                          |
|-------------|-----------|--------------------------------------|
| Primär      | `#B0892D` | Buttons, Akzente, Überschriften-Linie |
| Sekundär    | `#252525` | Fließtext, Navigation, Footer         |
| Tertiär     | `#C4C4C4` | Trennlinien, dezente Flächen          |

Definiert in `_sass/_variables.scss` – dort auch die Bootstrap-Farb-Map
(`$theme-colors`), damit z.&nbsp;B. `btn-primary` automatisch in Gold erscheint.

## Projektstruktur

```
.
├── _config.yml            # Grundeinstellungen, Bandkontakt, Social Links
├── _data/
│   ├── mitglieder.yml      # Bandmitglieder (Name, Instrument, optional Foto)
│   ├── anlaesse.yml        # Anlässe auf der Seite "Über uns" (Name + Icon)
│   ├── sponsoren.yml       # Sponsoren (Name, Logo, Website, optional "haupt")
│   ├── termine.yml         # kommende Konzerttermine (wird beim Build
│   │                        # automatisch von der Konzertmeister-API
│   │                        # überschrieben)
│   └── termine_vergangen.yml   # vergangene Termine des laufenden
│                                # Kalenderjahres (dito automatisch)
├── _includes/               # head, footer, sponsor-card
├── _layouts/                 # default, home (Schriftzug-Hero + Klick auf Startseite)
├── _plugins/
│   └── bootstrap_sass_paths.rb   # bindet den Sass-Quellordner der Bootstrap-Gem ein
├── _sass/
│   ├── _variables.scss     # Bootstrap-Variablen VOR dem Import überschreiben
│   └── _custom.scss        # eigene Komponenten (Hero, Karten, Footer, Sektionen)
├── assets/
│   ├── css/main.scss       # Sass-Einstiegspunkt → wird zu assets/css/main.css
│   ├── js/main.js
│   ├── brand/               # Logo, Schriftzug, Unterstreichung (SVG)
│   ├── vendor/fontawesome/  # lokal gehostetes Font Awesome (Icons)
│   └── img/                # eigene Bilder (Favicon, Sponsoren-Logos etc.)
├── script/
│   └── fetch_termine.rb    # holt Termine von der Konzertmeister-API
├── index.html, ueber-uns.html, termine.html, sponsoren.html, impressum.html
├── Gemfile
└── .github/workflows/
    ├── pages.yml            # Build & Deploy nach GitHub Pages
    └── release.yml          # automatisches Release-Tagging
```

## GitHub-Actions-Workflows

GitHub Pages baut Jekyll-Seiten standardmäßig im **Safe Mode** mit dem
`github-pages`-Gem und lässt dabei keine zusätzlichen Gems wie `bootstrap`
oder eigene `_plugins` zu. Deshalb baut `.github/workflows/pages.yml` die
Seite selbst per `bundle exec jekyll build` und lädt nur das fertige
`_site`-Verzeichnis zu GitHub Pages hoch. Zusätzlich zum Push nach `main`
baut der Workflow die Seite auch täglich per `schedule` neu, damit
neue/geänderte Konzertmeister-Termine auch ohne Code-Änderung erscheinen.

**Einmalig im Repository einrichten:** Settings → Pages → *Build and
deployment* → Source auf **„GitHub Actions"** stellen.

`.github/workflows/release.yml` erstellt bei jedem Push nach `main`
automatisch einen Git-Tag + GitHub-Release nach dem Schema
`YYYY.MM.VERSION` (z.&nbsp;B. `2026.08.1`) – `VERSION` zählt pro
Kalendermonat neu ab 1 hoch. Kein manuelles Einrichten nötig, läuft mit den
Standard-Repository-Rechten (`contents: write`).

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

Der Workflow (`.github/workflows/pages.yml`) reicht das Secret nur während
des Build-Jobs als Umgebungsvariable an das Fetch-Script durch – der Key
landet nie im ausgelieferten `_site`-Verzeichnis und ist für Website-
Besucher:innen nicht einsehbar.

**Lokal mit echten Daten arbeiten** (optional): Key nur für den einen
Aufruf als Umgebungsvariable setzen, nicht dauerhaft exportieren:

```bash
KONZERTMEISTER_API_KEY="dein-key" bundle exec ruby script/fetch_termine.rb
```

Ohne gesetzten Key bleiben die zuletzt im Repo vorhandenen
`_data/termine*.yml` unverändert – lokales Entwickeln funktioniert also auch
ohne Key.
