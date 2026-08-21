# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Static marketing website for the brass band **Wonderbrass**, built with **Jekyll** and **Bootstrap 5 (Sass version)**, deployed to **GitHub Pages** via GitHub Actions. Site content and copy are in German.

## Commands

```bash
bundle install                       # install gems (first time / after Gemfile changes)
bundle exec jekyll serve             # local dev server with live reload, http://localhost:4000
bundle exec jekyll build             # production build → _site/
KONZERTMEISTER_API_KEY="..." bundle exec ruby script/fetch_termine.rb   # refresh _data/termine*.yml with real data
```

There is no test suite or linter configured for this repo.

Note: `_config.yml` sets `baseurl: "/wonderbrass-blechsound.de"`, so when running `jekyll serve` locally the site is served under `http://localhost:4000/wonderbrass-blechsound.de/`, not the bare root.

## Architecture

**Standard Jekyll layout**: page content lives in the top-level `.html` files (`index.html`, `ueber-uns.html`, `termine.html`, `sponsoren.html`, `impressum.html`), each rendered through `_layouts/default.html` (or `_layouts/home.html` for the homepage hero). Shared chrome is in `_includes/` (`head.html`, `footer.html`, `sponsor-card.html`).

**Content is data-driven, not hardcoded in templates.** Band members, sponsors, occasions, and concert dates all live in `_data/*.yml` and are looped over in the page templates — edit the YAML, not the HTML, to change this content:
- `_data/mitglieder.yml` — band members (name, instrument, optional photo)
- `_data/anlaesse.yml` — occasions shown on "Über uns" (name + icon)
- `_data/sponsoren.yml` — sponsors (name, logo, website, optional `haupt` flag for main sponsors)
- `_data/termine.yml` / `_data/termine_vergangen.yml` — upcoming / past concert dates. **These two files are auto-generated on every build** (see below) — don't hand-edit them expecting changes to stick.

**Concert dates come from an external API, not from git.** `script/fetch_termine.rb` calls the [Konzertmeister](https://konzertmeister.app) API before every `jekyll build` and overwrites `_data/termine.yml` (upcoming) and `_data/termine_vergangen.yml` (past, current calendar year only, newest first). Only appointments of type *Performance*, status *active*, and explicitly flagged `publicsite: true` in Konzertmeister are pulled in. The script reads the key exclusively from the `KONZERTMEISTER_API_KEY` env var, is a no-op (exit 0, files left untouched) if the var is unset — so local dev works fine without a key — and never writes the key anywhere. The key is stored as the GitHub Actions repository secret `KONZERTMEISTER_API_KEY` and must never be committed. The script also converts UTC timestamps to `Europe/Berlin` and pre-formats German weekday/month names via `tzinfo`, because Liquid's `date` filter can't be trusted for German locale/DST on the build server.

**Sass/Bootstrap pipeline**: `assets/css/main.scss` is the Sass entry point (front matter required, even empty, for Jekyll to process it) and imports, in order: `_variables.scss` → `_fonts.scss` → `bootstrap` → `_custom.scss`. `_sass/_variables.scss` overrides Bootstrap's Sass variables (colors, fonts, `$theme-colors` map) *before* Bootstrap is imported, so components like `btn-primary` automatically pick up the brand gold. Brand colors: primary gold `#B0892D`, secondary dark `#252525`, tertiary grey `#C4C4C4` — see the table in README.md. `_plugins/bootstrap_sass_paths.rb` is a Jekyll hook that registers the `bootstrap` gem's own stylesheets directory as a Sass load path (via `Gem::Specification`, since the gem no longer exposes a `Bootstrap.load_path` API) so `@import "bootstrap"` resolves without vendoring Bootstrap's source. Font Awesome is vendored locally under `assets/vendor/fontawesome/`.

**GitHub Pages deploy is NOT the default Jekyll safe-mode build.** GitHub Pages' built-in build (via the `github-pages` gem) doesn't allow the `bootstrap` gem or custom `_plugins`, which this site needs. `.github/workflows/pages.yml` therefore builds the site itself (`bundle exec jekyll build`) and uploads only the resulting `_site/` artifact to Pages. This workflow also runs on a daily `schedule` (05:00 UTC) in addition to push-to-`main`, purely so newly added/changed Konzertmeister appointments show up without a code change. Repo setting required once: Settings → Pages → Build and deployment → Source = "GitHub Actions".

**Releases are automatic**: `.github/workflows/release.yml` tags every push to `main` as `YYYY.MM.N` (N resets to 1 each calendar month) and creates a GitHub Release with auto-generated notes. No manual versioning needed.