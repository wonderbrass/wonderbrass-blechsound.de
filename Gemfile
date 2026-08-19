source "https://rubygems.org"

gem "jekyll", "~> 4.3"

# Bootstrap als Sass-Version einbinden (Quelle: node_modules-freie Ruby-Gem)
gem "bootstrap", "~> 5.3"

# Jekyll benötigt für Sass-Kompilierung Dart-Sass
gem "jekyll-sass-converter", "~> 3.0"

# Lokaler Server unter Ruby 3.x
gem "webrick", "~> 1.8"

group :jekyll_plugins do
  gem "jekyll-feed"
  gem "jekyll-sitemap"
  gem "jekyll-seo-tag"
end

# Windows/JRuby Zeitzonen-Fix (schadet auf Linux/Mac nicht)
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1", :platforms => [:mingw, :x64_mingw, :mswin]
