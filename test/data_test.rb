# frozen_string_literal: true

# Tests for the data files in _data/: required fields and the images they point to. A
# typo here otherwise shows up as an empty card or a broken image on the website.

require "test_helper"

class DataTest < Minitest::Test
  def assert_repository_file(path, context)
    assert File.file?(File.join(ROOT, path)), "#{context}: #{path} does not exist"
  end

  def test_every_member_has_a_name_an_instrument_and_an_existing_photo
    data("mitglieder").each do |member|
      refute_empty member["name"].to_s, "member without name: #{member}"
      refute_empty member["instrument"].to_s, "#{member["name"]}: instrument missing"
      assert_repository_file "assets/img/mitglieder/#{member["foto"]}", member["name"] if member["foto"]
    end
  end

  def test_every_sponsor_has_a_name_and_valid_optional_fields
    data("sponsoren").each do |sponsor|
      refute_empty sponsor["name"].to_s, "sponsor without name: #{sponsor}"
      assert_repository_file "assets/img/sponsoren/#{sponsor["logo"]}", sponsor["name"] if sponsor["logo"]
      assert_match %r{\Ahttps?://}, sponsor["url"], "#{sponsor["name"]}: invalid url" if sponsor["url"]
      assert_includes [nil, true, false], sponsor["haupt"], "#{sponsor["name"]}: haupt must be true or false"
    end
  end

  def test_sponsor_names_are_unique
    names = data("sponsoren").map { |sponsor| sponsor["name"] }
    assert_empty names.tally.select { |_name, count| count > 1 }.keys
  end

  def test_occasions_have_a_name_and_an_icon
    data("anlaesse").each do |occasion|
      refute_empty occasion["name"].to_s
      assert_match(/\Afa-[a-z0-9-]+\z/, occasion["icon"], "#{occasion["name"]}: icon must be a Font Awesome class")
    end
  end

  def test_navigation_entries_are_complete
    data("navigation").each do |entry|
      refute_empty entry["title"].to_s, "navigation: #{entry} without title"
      assert_match %r{\A/}, entry["url"], "navigation: #{entry["title"]} needs an absolute url"
    end
  end

  def test_imprint_sections_have_title_and_text
    sections = data("impressum")["abschnitte"]
    refute_empty sections
    sections.each do |section|
      refute_empty section["titel"].to_s
      refute_empty section["text"].to_s, "#{section["titel"]} without text"
    end
  end
end
