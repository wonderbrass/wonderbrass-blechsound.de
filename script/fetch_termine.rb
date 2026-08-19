#!/usr/bin/env ruby
# frozen_string_literal: true

# Holt die Konzerttermine über die Konzertmeister-API und schreibt sie nach
# _data/termine.yml (kommende Termine) und _data/termine_vergangen.yml
# (vergangene Termine des laufenden Kalenderjahres). Wird vor "jekyll build"
# ausgeführt (siehe .github/workflows/pages.yml bzw. README).
#
# Der API-Key wird ausschließlich über die Umgebungsvariable
# KONZERTMEISTER_API_KEY gelesen und landet nie im Repository. In GitHub
# Actions kommt er aus einem verschlüsselten Repository-Secret; lokal kann
# er beim Aufruf gesetzt werden. Ist keine Umgebungsvariable gesetzt, bricht
# das Script NICHT ab, sondern behält die zuletzt im Repo vorhandenen
# _data/termine*.yml bei (praktisch für lokale Entwicklung ohne Key).

require "net/http"
require "uri"
require "json"
require "yaml"
require "time"
require "tzinfo"

API_URL = "https://rest.konzertmeister.app/api/v4/org/m2m/appointments"
TYPE_PERFORMANCE = 2
OUTPUT_PATH = File.join(__dir__, "..", "_data", "termine.yml")
PAST_OUTPUT_PATH = File.join(__dir__, "..", "_data", "termine_vergangen.yml")
DEFAULT_TIMEZONE = "Europe/Berlin"

BASE_FILTERS = {
  typeIds: [TYPE_PERFORMANCE],
  activationStatusList: ["ACTIVE"],
  publishedStatus: "PUBLISHED",
  sortMode: "STARTDATE",
}.freeze

# Liquids "date"-Filter nutzt für %A/%B/%H die System-Locale bzw. UTC, was
# auf den meisten Servern/CI-Runnern zu falschen (englischen bzw. nicht an
# die Sommerzeit angepassten) Werten führt. Deshalb rechnen wir hier per
# tzinfo einmalig UTC → Europe/Berlin um und formatieren Wochentag/Monat
# selbst auf Deutsch – die Templates zeigen die fertigen Strings nur an.
WOCHENTAGE_KURZ = %w[So Mo Di Mi Do Fr Sa].freeze
WOCHENTAGE_LANG = %w[Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag].freeze
MONATE_KURZ = %w[Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez].freeze
MONATE_LANG = %w[
  Januar Februar März April Mai Juni Juli August September Oktober November Dezember
].freeze

def fetch_page(api_key, filters, page)
  uri = URI(API_URL)
  request = Net::HTTP::Post.new(uri)
  request["X-KM-ORG-API-KEY"] = api_key
  request["Content-Type"] = "application/json"
  request.body = filters.merge(page: page).to_json

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }

  unless response.is_a?(Net::HTTPSuccess)
    warn "Konzertmeister-API antwortete mit #{response.code}: #{response.body}"
    exit 1
  end

  JSON.parse(response.body)
end

def fetch_all_appointments(api_key, filters)
  appointments = []
  page = 0

  loop do
    batch = fetch_page(api_key, filters, page)
    break if batch.empty?

    appointments.concat(batch)
    page += 1
  end

  appointments
end

def local_time(iso_string, timezone_id)
  timezone = TZInfo::Timezone.get(timezone_id)
  timezone.utc_to_local(Time.iso8601(iso_string).utc)
end

def to_termin(appointment)
  location = appointment["location"] || {}
  ort = location["formattedAddress"] || location["name"] || ""
  timezone_id = appointment["timezoneId"] || DEFAULT_TIMEZONE

  start_local = local_time(appointment["start"], timezone_id)
  end_local = appointment["end"] ? local_time(appointment["end"], timezone_id) : nil

  {
    "titel" => appointment["name"],
    "beschreibung" => appointment["description"] || "",
    "ort" => ort,
    "start" => appointment["start"],
    "wochentag_kurz" => WOCHENTAGE_KURZ[start_local.wday],
    "wochentag_lang" => WOCHENTAGE_LANG[start_local.wday],
    "tag" => start_local.day,
    "monat_kurz" => MONATE_KURZ[start_local.mon - 1],
    "monat_lang" => MONATE_LANG[start_local.mon - 1],
    "jahr" => start_local.year,
    "zeit_unbekannt" => appointment["timeUndefined"] || false,
    "uhrzeit_start" => start_local.strftime("%H:%M"),
    "uhrzeit_ende" => end_local&.strftime("%H:%M"),
  }
end

def public_termine(appointments)
  # Nur Termine, die die Band explizit für die öffentliche Website freigegeben hat.
  appointments.select { |a| a["publicsite"] }.map { |a| to_termin(a) }
end

api_key = ENV["KONZERTMEISTER_API_KEY"]

if api_key.nil? || api_key.empty?
  warn "KONZERTMEISTER_API_KEY ist nicht gesetzt – _data/termine*.yml bleiben unverändert."
  exit 0
end

now_utc = Time.now.utc
current_year = local_time(now_utc.iso8601, DEFAULT_TIMEZONE).year

upcoming_filters = BASE_FILTERS.merge(dateMode: "UPCOMING")
past_filters = BASE_FILTERS.merge(
  dateMode: "FROM_DATE",
  filterStart: format("%04d-01-01T00:00:00+00:00", current_year),
  filterEnd: now_utc.strftime("%Y-%m-%dT%H:%M:%S+00:00"),
)

upcoming_termine = public_termine(fetch_all_appointments(api_key, upcoming_filters))
  .sort_by { |t| t["start"] }

# Nur das laufende Kalenderjahr, neueste zuerst.
vergangene_termine = public_termine(fetch_all_appointments(api_key, past_filters))
  .sort_by { |t| t["start"] }
  .reverse

File.write(OUTPUT_PATH, upcoming_termine.to_yaml)
File.write(PAST_OUTPUT_PATH, vergangene_termine.to_yaml)
puts "#{upcoming_termine.length} kommende(r) und #{vergangene_termine.length} " \
     "vergangene(r) Termin(e) von der Konzertmeister-API geschrieben."
