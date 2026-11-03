# CLAUDE.md

Allgemeine Regeln (Git Flow, Merge-Art, Sprache, Commits, PRs, Issues, Inline-Doku, Docker-Images)
stehen im Repo `konventionen` und werden hier nicht wiederholt. Diese Datei beschreibt nur dieses Repo.

## Überblick

Statische Website der Brass-Combo **Wonderbrass**, gebaut mit **Jekyll** und **Bootstrap 5 (Sass-Version)**, veröffentlicht auf **GitHub Pages** über GitHub Actions. Inhalte und Texte der Seite sind Deutsch.

Die Seite läuft unter der eigenen Domain `wonderbrass-blechsound.de` (siehe `CNAME` im Wurzelverzeichnis), deshalb setzt `_config.yml` `baseurl: ""`. `jekyll serve` liefert lokal direkt unter `http://localhost:4000/` aus.

## Befehle

```bash
bundle install                       # Gems installieren (erstes Mal oder nach Änderungen am Gemfile)
bundle exec jekyll serve             # lokaler Server mit Live-Reload, http://localhost:4000
bundle exec jekyll build             # Produktions-Build nach _site/
KONZERTMEISTER_API_KEY="..." bundle exec ruby script/fetch_termine.rb   # _data/termine*.yml mit echten Daten füllen
```

Keine Tests und kein Linter.

### Termine aus Konzertmeister lokal holen

`_data/termine.yml` erzeugt die CI vor jedem Build neu (siehe unten) und soll eigentlich in der `.gitignore` stehen, damit echte Daten lokal gefahrlos geholt werden können. **Achtung:** Derzeit sind `_data/termine.yml` und `_data/termine_vergangen.yml` noch versioniert (Überbleibsel aus der Zeit vor den Ignore-Regeln, dazu ein Tippfehler in `.gitignore`: `termine-vergangen.yml` statt `termine_vergangen.yml`). Lokale Änderungen daran also nicht als wegwerfbar ansehen, bis das bereinigt ist.

```bash
KONZERTMEISTER_API_KEY="dein-key" bundle exec ruby script/fetch_termine.rb
```

Ohne Schlüssel endet das Skript mit Code 0 und lässt `_data/termine.yml` unverändert (oder fehlend bei einem frischen Klon). Lokale Builds funktionieren trotzdem, das Include zeigt dann „keine Termine“.

`.env.example` dokumentiert die erwartete Variable (`KONZERTMEISTER_API_KEY=`). Kopieren nach `.env` und echten Schlüssel eintragen, beide Dateien stehen in der `.gitignore`. Nichts im Repo lädt `.env` automatisch (kein `dotenv`-Gem), die Variable vor dem Skript selbst exportieren.

## Architektur

**Standard-Aufbau von Jekyll**: Die Seiteninhalte liegen in den `.html`-Dateien im Wurzelverzeichnis (`index.html`, `ueber-uns.html`, `termine.html`, `sponsoren.html`, `impressum.html`) und werden über `_layouts/default.html` gerendert. Die Startseite nutzt `_layouts/home.html`, das `{{ content }}` in einen Hero-Bereich mit dem eingebetteten Logo `WB-Schriftzug.svg` setzt. Gemeinsame Teile liegen in `_includes/`: `head.html`, `header.html` (fixierte Navigationsleiste), `footer.html`, `sponsor-card.html`.

**Navigation** steht in `_data/navigation.yml` (Paare aus Titel und URL), `_includes/header.html` läuft darüber. Die Leiste (`.navbar-brasscombo` in `_sass/_custom.scss`) ist oben fixiert, zentriert das Logo auf dem Handy, wechselt per `prefers-color-scheme` zwischen hellem und dunklem Logo und hat statt des Bootstrap-Standards eine eigene Animation vom Hamburger zum X. Der Umschalter ist auch auf dem Desktop sichtbar (überschreibt `.navbar-expand-md .navbar-toggler`), weil das ausklappbare Menü dort ebenfalls genutzt wird.

**Inhalte kommen aus Daten, nicht aus den Vorlagen.** Mitglieder, Sponsoren, Anlässe und Konzerttermine stehen in `_data/*.yml` und werden in den Seitenvorlagen durchlaufen. Zum Ändern das YAML bearbeiten, nicht das HTML:
- `_data/mitglieder.yml`: Bandmitglieder (Name, Instrument, optional Foto)
- `_data/anlaesse.yml`: Anlässe auf „Über uns“ (Name und Icon)
- `_data/sponsoren.yml`: Sponsoren (Name, Logo, Website, optional `haupt` für Hauptsponsoren)
- `_data/termine.yml` / `_data/termine_vergangen.yml`: kommende und vergangene Konzerttermine. **Beide Dateien entstehen bei jedem Build neu** (siehe unten), Änderungen von Hand bleiben nicht erhalten.

**Konzerttermine kommen aus einer externen API, nicht aus Git.** `script/fetch_termine.rb` ruft vor jedem `jekyll build` die API von [Konzertmeister](https://konzertmeister.app) ab und überschreibt `_data/termine.yml` (kommende) und `_data/termine_vergangen.yml` (vergangene, nur aktuelles Kalenderjahr, neueste zuerst). Übernommen werden nur Termine vom Typ *Performance* mit Status *active*, die in Konzertmeister ausdrücklich mit `publicsite: true` markiert sind. Den Schlüssel liest das Skript nur aus `KONZERTMEISTER_API_KEY`. Ist die Variable leer, tut es nichts (Code 0, Dateien bleiben), lokal geht es also auch ohne Schlüssel. Der Schlüssel wird nirgends geschrieben, liegt als Repository-Secret `KONZERTMEISTER_API_KEY` in GitHub Actions und darf nie committet werden. Das Skript rechnet UTC-Zeitstempel nach `Europe/Berlin` um und formatiert deutsche Wochentags- und Monatsnamen schon vorab über `tzinfo`, weil der `date`-Filter von Liquid auf dem Build-Server bei Gebietsschema und Sommerzeit nicht verlässlich ist.

**Sass/Bootstrap**: `assets/css/main.scss` ist der Einstieg (braucht Front Matter, auch leer, damit Jekyll es verarbeitet) und importiert in dieser Reihenfolge: `_variables.scss` → `_fonts.scss` → `bootstrap` → `font-awesome` → `_custom.scss`. `_sass/_variables.scss` überschreibt die Sass-Variablen von Bootstrap (Farben, Schriften, `$theme-colors`) *vor* dem Import, so übernehmen Komponenten wie `btn-primary` automatisch das Gold der Marke. Markenfarben: Gold `#B0892D` (primär), Dunkel `#252525` (sekundär), Grau `#C4C4C4` (tertiär), siehe Tabelle im README. `_plugins/bootstrap_sass_paths.rb` ist ein Jekyll-Hook, der das Stylesheet-Verzeichnis des Gems `bootstrap` als Sass-Ladepfad registriert (über `Gem::Specification`, weil das Gem keine API `Bootstrap.load_path` mehr hat). So löst sich `@import "bootstrap"` auf, ohne die Quellen einzuchecken. Font Awesome funktioniert genauso über das Gem `font-awesome-sass` und `_plugins/font_awesome_sass_paths.rb`.

## CI und Release

**Der Deploy auf GitHub Pages ist nicht der Standard-Build von Jekyll im Safe Mode.** Der eingebaute Build von GitHub Pages (Gem `github-pages`) erlaubt weder das Gem `bootstrap` noch eigene `_plugins`, die diese Seite braucht. `.github/workflows/pages.yml` baut die Seite deshalb selbst (`bundle exec jekyll build`) und lädt nur das Ergebnis `_site/` zu Pages hoch. Der Workflow läuft zusätzlich zum Push auf `main` täglich um 05:00 UTC, damit neue oder geänderte Termine aus Konzertmeister ohne Code-Änderung erscheinen. Einmalig nötige Einstellung: Settings → Pages → Build and deployment → Source = „GitHub Actions“.

`.github/workflows/release.yml` erzeugt bei jedem Push auf `main` Tag und Release im Schema `YYYY.MM.N` mit automatisch erzeugten Notes.

## Abweichungen von den Konventionen

Keine.
