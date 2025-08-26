#!/usr/bin/env ruby

# frozen_string_literal: true

require "dotenv"
require "optparse"
require_relative "lml_client"
require_relative "reddit_client"

Dotenv.load

def main(opts)
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
  post_text = String.new

  gigs.each do |gig|
    post_text << gig.to_reddit_s
    post_text << "\n\n"
  end

  post_text << "\n\n"
  post_text << "Live Music Locator is a not-for-profit service designed to " \
    "make it possible to discover every gig playing at every venue across " \
    "every genre at any one time. This information will always be verified " \
    "and free, importantly supporting musicians, our small to medium live " \
    "music venues, and you the punters. More detailed gig information here: " \
    "https://lml.live/?dateRange=today"

  if opts[:dryrun]
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
  opts = {:dryrun => false}

  OptionParser.new do |parser|
    parser.banner = "Usage: #{__FILE__} [OPTIONS]"
    parser.on("-d", "--dry-run", "Dry run - prints list of gigs to stdout, but doesn't post to reddit") do
      opts[:dryrun] = true
    end
    parser.parse!
  end

  main(opts.freeze)
end
