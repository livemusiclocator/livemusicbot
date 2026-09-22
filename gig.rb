# frozen_string_literal: true

class Gig
  attr_reader :id, :name, :date, :venue

  def initialize(id:, name:, date:, venue:)
    @id = id
    @name = name
    @date = date
    @venue = venue
  end

  def lml_url
    "https://www.livemusiclocator.com.au/gigs/#{@id}"
  end

  def display_name
    "#{@name} - #{@venue} - #{@date.strftime("%a, %d %b %Y")}"
  end

  def reddit_discussion_url
    "https://reddit.com/r/livemusicmelbourne/submit?url=#{lml_url}&title=#{CGI.escape(display_name)}"
  end
end
