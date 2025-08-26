# frozen_string_literal: true

require "faraday"
require_relative "gig"

class LmlClient
  attr_reader :conn

  HOSTNAME = "https://api.lml.live"

  def initialize
    @conn ||= Faraday.new(url: HOSTNAME) do |f|
      f.response(:json)
    end
  end

  def gigs(location: "melbourne")
    today = Time.new
    start_of_today = Time.new(today.year, today.month, today.day, 0, 0, 0)

    url = "/gigs/query?date_from=#{start_of_today}&date_to=#{start_of_today}&location=#{location}"

    @conn.get(url).body.map { |gig| Gig.from_lml(gig) }
  end
end
