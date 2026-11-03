# frozen_string_literal: true

# Tests for the built site: links, images and scripts (html-proofer), files that must
# not be published, the appointment pages and the pages built from _data/. The site is
# built with appointments from test/fixtures and a second time without any.

require "html-proofer"
require "test_helper"

class SiteTest < Minitest::Test
  # Files of the repository that must never end up on the website
  INTERNAL_FILES = %w[Gemfile Gemfile.lock README.md Rakefile test .env .env.example .github .forgejo].freeze

  def past_appointments
    [to_termin(appointments[0].merge("name" => "Frühjahrskonzert", "start" => "2026-04-25T17:00:00Z", "end" => nil))]
  end

  def site
    SiteBuild.build(data: { "termine" => public_termine(appointments), "termine_vergangen" => past_appointments })
  end

  def site_without_appointments
    SiteBuild.build(data: { "termine" => [], "termine_vergangen" => [] })
  end

  # Runs html-proofer on the built site and returns its findings instead of exiting.
  #
  # @return [Array<String>] one line per failure
  def proofer_failures
    proofer = HTMLProofer.check_directory(site, disable_external: true, checks: %w[Links Images Scripts],
                                                log_level: :fatal)
    begin
      proofer.run
    rescue SystemExit
      nil # html-proofer exits on failures, the findings stay readable
    end
    proofer.failed_checks.map { |failure| "#{failure.path}:#{failure.line} #{failure.description}" }
  end

  def test_links_images_and_scripts_resolve
    assert_empty proofer_failures
  end

  def test_repository_files_are_not_published
    published = INTERNAL_FILES.select { |file| File.exist?(File.join(site, file)) }
    assert_empty published
  end

  def test_claude_md_and_the_script_are_not_published
    skip "CLAUDE.md und script/ werden veröffentlicht, Issue #4"
    refute File.exist?(File.join(site, "CLAUDE.md"))
    refute File.exist?(File.join(site, "script"))
  end

  def test_every_page_has_a_title
    Dir.glob("**/*.html", base: site).each do |file|
      title = page(site, file)[%r{<title>(.*?)</title>}m, 1].to_s.strip
      refute_empty title, "#{file} has no title"
    end
  end

  def test_the_next_appointment_is_featured_with_long_date_and_time
    html = page(site, "termine/index.html")
    featured = html[/gig-card-featured.*?<\/div>/m]

    assert_includes featured, "Samstag, 18. Juli 2026"
    assert_includes featured, "17:30–23:00 Uhr"
    assert_includes featured, "Sommerfest"
    assert_includes featured, "Tannwaldstraße 16, 72401 Haigerloch, Deutschland"
  end

  def test_further_appointments_follow_without_unknown_times
    html = page(site, "termine/index.html")

    assert_includes html, "Weitere Termine"
    assert_includes html, "Sa, 5. Dez 2026"
    refute_includes html, "19:00 Uhr", "an appointment without time shows no time"
    refute_includes html, "Interne Probe"
  end

  def test_past_appointments_are_listed
    html = page(site, "termine/index.html")

    assert_includes html, "Vergangene Termine"
    assert_includes html, "Frühjahrskonzert"
    assert_includes html, "Sa, 25. Apr 2026"
  end

  def test_without_appointments_a_note_is_shown
    html = page(site_without_appointments, "termine/index.html")

    assert_includes html, "Aktuell sind keine Termine geplant"
    refute_includes html, "Vergangene Termine"
    refute_includes html, "Weitere Termine"
  end

  def test_the_home_page_shows_at_most_three_appointments
    termine = Array.new(5) { |i| to_termin(appointments[0].merge("name" => "Termin #{i + 1}")) }
    html = page(SiteBuild.build(data: { "termine" => termine, "termine_vergangen" => [] }), "index.html")

    assert_includes html, "Termin 3"
    refute_includes html, "Termin 4"
  end

  def test_every_member_is_listed_with_photo
    html = page(site, "ueber-uns/index.html")
    data("mitglieder").each do |member|
      assert_includes html, member["name"]
      assert_includes html, "/assets/img/mitglieder/#{member["foto"]}" if member["foto"]
    end
  end

  def test_every_sponsor_is_listed_and_main_sponsors_come_first
    html = page(site, "sponsoren/index.html")
    sponsors = data("sponsoren")
    sponsors.each { |sponsor| assert_includes html, sponsor["name"] }

    last_main = sponsors.select { |s| s["haupt"] }.map { |s| html.index(s["name"]) }.max
    first_other = sponsors.reject { |s| s["haupt"] }.map { |s| html.index(s["name"]) }.min
    assert_operator last_main, :<, first_other
  end

  def test_imprint_shows_the_contact
    html = page(site, "impressum/index.html")
    site_config = YAML.safe_load_file(File.join(ROOT, "_config.yml"))
    site_config["contact"].each_value { |value| assert_includes html, value }
  end

  def test_navigation_points_to_existing_pages
    data("navigation").each do |entry|
      assert File.file?(File.join(site, entry["url"], "index.html")), "navigation: #{entry["url"]} is not built"
    end
  end

  def test_every_occasion_icon_exists_in_font_awesome
    stylesheet = page(site, "assets/css/main.css")
    data("anlaesse").each do |occasion|
      assert_includes stylesheet, ".#{occasion["icon"]}", "#{occasion["icon"]} is not part of Font Awesome"
    end
  end
end
