# Brass Combo – Website (Jekyll + Bootstrap Sass)

Grundstruktur für die Bandwebsite, strukturell an **viera-blech.at** angelehnt
(Logo + Navigation, großer Hero-Bereich, Termine, Footer mit Bandkontakt &
Social Media), umgesetzt mit **Jekyll** und **Bootstrap als Sass-Version**,
bereit für **GitHub Pages**.

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
│   ├── navigation.yml      # Hauptnavigation (frei erweiterbar)
│   ├── mitglieder.yml      # Bandmitglieder (Name, Instrument, optional Foto)
│   ├── anlaesse.yml        # Anlässe auf der Seite "Über uns" (Name + Icon)
│   ├── sponsoren.yml       # Sponsoren (Name, Logo, Website, optional "haupt")
│   ├── termine.yml         # kommende Konzerttermine (wird beim Build
│   │                        # automatisch von der Konzertmeister-API
│   │                        # überschrieben)
│   └── termine_vergangen.yml   # vergangene Termine des laufenden
│                                # Kalenderjahres (dito automatisch)
├── _includes/               # head, header/navbar, footer
├── _layouts/                 # default, page, home
├── _plugins/
│   └── bootstrap_sass_paths.rb   # bindet den Sass-Quellordner der Bootstrap-Gem ein
├── _sass/
│   ├── _variables.scss     # Bootstrap-Variablen VOR dem Import überschreiben
│   └── _custom.scss        # eigene Komponenten (Hero, Navbar, Karten, Footer)
├── assets/
│   ├── css/main.scss       # Sass-Einstiegspunkt → wird zu assets/css/main.css
│   ├── js/main.js
│   ├── vendor/fontawesome/  # lokal gehostetes Font Awesome (Icons)
│   └── img/                # eigene Bilder (Favicon etc.) hier ablegen
├── script/
│   └── fetch_termine.rb    # holt Termine von der Konzertmeister-API
├── index.html, ueber-uns.md, termine.html, sponsoren.html
├── impressum.md
├── Gemfile
└── .github/workflows/pages.yml   # Build & Deploy nach GitHub Pages
```

## Warum ein GitHub-Actions-Workflow?

GitHub Pages baut Jekyll-Seiten standardmäßig im **Safe Mode** mit dem
`github-pages`-Gem und lässt dabei keine zusätzlichen Gems wie `bootstrap`
oder eigene `_plugins` zu. Deshalb baut `.github/workflows/pages.yml` die
Seite selbst per `bundle exec jekyll build` und lädt nur das fertige
`_site`-Verzeichnis zu GitHub Pages hoch.

**Einmalig im Repository einrichten:** Settings → Pages → *Build and
deployment* → Source auf **„GitHub Actions"** stellen.

## Konzertmeister-API (Termine)

Die Termine werden nicht mehr manuell gepflegt, sondern bei jedem Build von
[Konzertmeister](https://konzertmeister.app) über `script/fetch_termine.rb`
abgerufen. Übernommen werden nur Termine vom Typ *Performance*, mit Status
*aktiv* und die von der Band explizit für die öffentliche Website
freigegeben wurden (`publicsite: true` in Konzertmeister). Das Script
schreibt zwei Dateien:

- `_data/termine.yml` – alle kommenden Termine.
- `_data/termine_vergangen.yml` – bereits stattgefundene Termine des
  laufenden Kalenderjahres (ab 1. Januar), neueste zuerst. Werden auf
  `termine.html` unterhalb der kommenden Termine in einem eigenen,
  optisch zurückhaltenderen Block angezeigt.

**API-Key sicher hinterlegen:** Ein Konzertmeister-API-Key darf **niemals**
im Repository landen (GitHub Pages ist immer öffentlich erreichbar, egal ob
das Repo privat oder öffentlich ist). Stattdessen als **verschlüsseltes
Repository-Secret** hinterlegen:

Settings → Secrets and variables → Actions → *New repository secret* →
Name `KONZERTMEISTER_API_KEY`, Wert der API-Key.

Der Workflow (`.github/workflows/pages.yml`) reicht das Secret nur während
des Build-Jobs als Umgebungsvariable an das Fetch-Script durch – der Key
landet nie im ausgelieferten `_site`-Verzeichnis und ist für Website-
Besucher:innen nicht einsehbar. Zusätzlich zum Push-Trigger baut der
Workflow die Seite auch täglich per `schedule` neu, damit neue/geänderte
Termine auch ohne Code-Änderung erscheinen.

**Lokal mit echten Daten arbeiten** (optional): Key nur für den einen
Aufruf als Umgebungsvariable setzen, nicht dauerhaft exportieren:

```bash
KONZERTMEISTER_API_KEY="dein-key" bundle exec ruby script/fetch_termine.rb
```

Ohne gesetzten Key bleiben die zuletzt im Repo vorhandenen
`_data/termine*.yml` unverändert – lokales Entwickeln funktioniert also auch
ohne Key.

## Lokal entwickeln

```bash
bundle install
bundle exec jekyll serve
# → http://localhost:4000/brass-combo/
```

## Vor dem ersten Deploy anpassen

1. `_config.yml`: `title`, `tagline`, `description`, `url`, `baseurl`
   (`baseurl` = `""`, falls die Seite unter einer eigenen Domain statt
   `<user>.github.io/<repo>` läuft) sowie `contact:` und `social:`.
2. `assets/img/`: eigenes Favicon als `favicon.png` ablegen.
3. `KONZERTMEISTER_API_KEY`-Secret hinterlegen (siehe oben), damit echte
   Termine erscheinen.
4. `ueber-uns.md`: Bandtext & Besetzung ersetzen.
5. Texte auf `impressum.md` ergänzen (in Österreich Pflichtangaben nach
   § 5 ECG bzw. § 25 MedienG). Enthält Impressum &amp; Datenschutz in einem.

## Bootstrap anpassen

Alle Bootstrap-Sass-Variablen (Radius, Abstände, Schriftgrößen, weitere
Farben) lassen sich in `_sass/_variables.scss` **vor** `@import "bootstrap"`
überschreiben – siehe die offizielle Bootstrap-Sass-Doku für die komplette
Variablenliste.
