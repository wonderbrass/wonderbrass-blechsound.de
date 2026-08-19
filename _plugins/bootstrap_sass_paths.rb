# Registriert den Sass-Quellordner der "bootstrap"-Gem als zusätzlichen
# Sass-Load-Path, damit `@import "bootstrap"` / `@use "bootstrap"` in
# assets/scss/main.scss funktioniert, ohne Bootstrap manuell zu kopieren.
require "bootstrap"

Jekyll::Hooks.register :site, :after_init do |site|
  site.config["sass"] ||= {}
  site.config["sass"]["load_paths"] ||= []
  site.config["sass"]["load_paths"] << Bootstrap.load_path
end
