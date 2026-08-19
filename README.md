# Brass Combo – Website (Jekyll + Bootstrap Sass)

Grundstruktur für die Bandwebsite, strukturell an **viera-blech.at** angelehnt
(Logo + Navigation, großer Hero-Bereich, Termine, Fotos, Kontakt, Footer mit
Bandkontakt & Social Media), umgesetzt mit **Jekyll** und **Bootstrap als
Sass-Version**, bereit für **GitHub Pages**.

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
│   └── termine.yml         # Konzerttermine
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
│   └── img/                # eigene Bilder (Hero, Galerie, Favicon) hier ablegen
├── index.html, ueber-uns.md, termine.html, fotos.html, kontakt.html
├── impressum.md, datenschutz.md
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
2. `assets/img/`: eigenes Hero-Bild als `hero-bg.jpg`, Favicon als
   `favicon.png`, Konzertfotos unter `assets/img/gallery/` ablegen.
3. `_data/termine.yml`: echte Konzerttermine eintragen.
4. `ueber-uns.md`: Bandtext & Besetzung ersetzen.
5. `kontakt.html`: `action`-URL des Kontaktformulars (z.&nbsp;B. Formspree)
   eintragen.
6. Texte auf `impressum.md` / `datenschutz.md` ergänzen (in Österreich
   Pflichtangaben nach § 5 ECG bzw. § 25 MedienG).

## Bootstrap anpassen

Alle Bootstrap-Sass-Variablen (Radius, Abstände, Schriftgrößen, weitere
Farben) lassen sich in `_sass/_variables.scss` **vor** `@import "bootstrap"`
überschreiben – siehe die offizielle Bootstrap-Sass-Doku für die komplette
Variablenliste.
