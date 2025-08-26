# frozen_string_literal: true

require "faraday"

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
