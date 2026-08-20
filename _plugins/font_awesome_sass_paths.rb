# Registriert den Sass-Quellordner der "font-awesome-sass"-Gem als
# zusätzlichen Sass-Load-Path, damit `@import "font-awesome"` in
# assets/css/main.scss funktioniert, ohne Font Awesome manuell zu
# kopieren.
#
# Hinweis: Die Gem versucht beim Laden selbst, sich in Rails/Sprockets
# einzuklinken (`FontAwesome::Sass.load!`). Da wir hier weder Rails noch
# Sprockets noch das veraltete "sass"-Gem nutzen, greift das nicht – der
# Sass-Load-Path muss daher wie bei Bootstrap manuell ergänzt werden.
require "font-awesome-sass"

Jekyll::Hooks.register :site, :after_init do |site|
  site.config["sass"] ||= {}
  site.config["sass"]["load_paths"] ||= []
  site.config["sass"]["load_paths"] << FontAwesome::Sass.stylesheets_path
end
