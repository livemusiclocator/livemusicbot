# frozen_string_literal: true

require "faraday"
require_relative "gig"

class LmlClient
  attr_reader :conn

  HOSTNAME = "https://api.lml.live"
  REQUIRED_FIELDS = %w[id name date venue].freeze

  def initialize
    @conn ||= Faraday.new(url: HOSTNAME) do |f|
      f.response(:json)
    end
  end

  def gigs(location: "melbourne")
    today = Time.new
    start_of_today = Time.new(today.year, today.month, today.day, 0, 0, 0)

    url = "/gigs/query?date_from=#{start_of_today}&date_to=#{start_of_today}&location=#{location}"

    @conn.get(url).body.map do |gig|
      REQUIRED_FIELDS.each do |field|
        raise "Missing required field #{field}" unless gig[field]
      end

      fields = {
        id: gig["id"],
        name: gig["name"],
        date: Date.parse(gig["date"]),
        venue: gig["venue"]["name"]
      }

      Gig.new(**fields)
    end
  end
end
