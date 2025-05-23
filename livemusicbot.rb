#!/usr/bin/env ruby

# frozen_string_literal: true

require "dotenv"
require "faraday"
require "optparse"

Dotenv.load

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

    @conn.get(url).body
  end
end

class RedditClient
  attr_reader :access_token, :conn

  HOSTNAME = "https://oauth.reddit.com"

  def initialize(client_id: nil, client_secret: nil, username: nil, password: nil)
    @auth = {
      client_id: client_id || ENV.fetch("REDDIT_CLIENT_ID"),
      client_secret: client_secret || ENV.fetch("REDDIT_CLIENT_SECRET"),
      username: username || ENV.fetch("REDDIT_USERNAME"),
      password: password || ENV.fetch("REDDIT_PASSWORD")
    }
  end

  def fetch_access_token
    conn = Faraday.new(url: "https://www.reddit.com") do |f|
      f.request(:authorization, :basic, @auth[:client_id], @auth[:client_secret])
      f.request(:url_encoded)
      f.response(:json)
    end

    res = conn.post("/api/v1/access_token", {
      grant_type: "password",
      username: @auth[:username],
      password: @auth[:password]
    })

    @access_token = res.body["access_token"]
  end

  def submit_post(kind, subreddit, title, text)
    make_connection!

    @conn.post("/api/submit", {
      kind: kind,
      sr: subreddit,
      title: title,
      text: text
    })
  end

  def me
    make_connection!

    @conn.get("/api/v1/me")
  end

  private

  def make_connection!
    raise "Missing access token" unless @access_token

    @conn ||= Faraday.new(url: HOSTNAME) do |f|
      f.request(:authorization, "Bearer", @access_token)
      f.request(:url_encoded)
      f.response(:json)
    end
  end
end

def to_reddit_s(gig)
  date = Date.parse(gig["date"]).strftime("%a, %d %b %Y")
  display_name = "#{gig["name"]} - #{gig["venue"]["name"]} - #{date}"
  lml_url = "https://lml.live/gigs/#{gig["id"]}"
  reddit_discussion_url = "https://reddit.com/r/livemusicmelbourne/submit?url=#{lml_url}&title=#{CGI.escape(display_name)}"

  "#{display_name} [[discuss](#{reddit_discussion_url})] [[view gig](#{lml_url})]"
end

def main(**options)
  puts "Finding today's gigs..."

  lml_client = LmlClient.new
  gigs = lml_client.gigs(location: "melbourne")

  if gigs.empty?
    puts "No gigs for today :("
    puts "I'm off to the pub. Bye for now."
    exit 0
  end

  subreddit = "livemusicmelbourne"
  post_title = "Today's gigs"
  post_text = gigs.map { |gig| to_reddit_s(gig) }.join("\n\n")
  post_text << "\n\n"
  post_text << "Live Music Locator is a not-for-profit service designed to " \
    "make it possible to discover every gig playing at every venue across " \
    "every genre at any one time. This information will always be verified " \
    "and free, importantly supporting musicians, our small to medium live " \
    "music venues, and you the punters. More detailed gig information here: " \
    "https://lml.live/?dateRange=today"

  if options[:dryrun]
    puts post_text
    exit 0
  end

  puts "Posting to reddit..."

  reddit_client = RedditClient.new
  reddit_client.fetch_access_token
  reddit_client.submit_post("self", subreddit, post_title, post_text)

  puts "Done!"
  puts "You can check it out here: https://old.reddit.com/r/livemusicmelbourne"
  puts "I'm off to the pub. Bye for now."
end

if __FILE__ == $0
  opts = {}
  OptionParser.new do |parser|
    parser.banner = "Usage: #{__FILE__} [OPTIONS]"
    parser.on("-d", "--dry-run", "Dry run - prints list of gigs to stdout, but doesn't post to reddit") do
      opts[:dryrun] = true
    end
    parser.parse!
  end

  main(**opts.freeze)
end
