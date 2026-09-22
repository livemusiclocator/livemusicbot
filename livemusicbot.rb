#!/usr/bin/env ruby

# frozen_string_literal: true

require "cgi"
require "dotenv"
require "erb"
require "optparse"
require_relative "lml_client"
require_relative "reddit_client"

Dotenv.load

def main(opts)
  puts "[#{Time.now}] Finding today's gigs...\n\n"

  lml_client = LmlClient.new
  gigs = lml_client.gigs(location: "melbourne")

  if gigs.empty?
    puts "No gigs for today :("
    puts "I'm off to the pub. Bye for now."
    exit 0
  end

  template = File.read(File.join(__dir__, "post.md.erb"))
  erb = ERB.new(template, trim_mode: "-")
  sanitize = lambda do |str|
    str.gsub("`", "")
  end

  subreddit = "livemusicmelbourne"
  post_title = "Today's gigs"
  post_text = erb.result(binding)

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
