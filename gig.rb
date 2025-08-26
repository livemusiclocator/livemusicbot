# frozen_string_literal: true

require "cgi"

class Gig
  attr_reader :id, :name, :date, :venue

  REQUIRED_FIELDS = %w[id name date venue].freeze

  def self.from_lml(gig)
    REQUIRED_FIELDS.each do |field|
      raise "Missing required field #{field}" unless gig[field]
    end

    fields = {
      id: gig["id"],
      name: gig["name"],
      date: Date.parse(gig["date"]),
      venue: gig["venue"]["name"]
    }

    new(**fields)
  end

  def initialize(id:, name:, date:, venue:)
    @id = id
    @name = name
    @date = date
    @venue = venue
  end

  def to_reddit_s
    display_name = "#{@name} - #{@venue} - #{@date.strftime("%a, %d %b %Y")}"
    lml_url = "https://lml.live/gigs/#{@id}"
    reddit_discussion_url =
      "https://reddit.com/r/livemusicmelbourne/submit?url=#{lml_url}&title=#{CGI.escape(display_name)}"

    "#{sanitize(display_name)} [[discuss](#{reddit_discussion_url})] [[view gig](#{lml_url})]"
  end

  private

  def sanitize(str)
    str.gsub("`", "")
  end
end
