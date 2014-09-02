#!/usr/bin/env ruby

require 'bundler/setup'
require 'dotenv'; Dotenv.load
require 'soundcloud'
require 'open-uri'
require 'open_uri_redirections'

# First there is the authentication part.
# This is example on how you can do it from command line.
client = SoundCloud.new(
  client_id: ENV.fetch("SC_CLIENT_ID"),
  client_secret: ENV.fetch("SC_CLIENT_SECRET")
)

# Warning! Please don't do this directly from your Rails application!
# This is a job that should be done in background by some kind of background worker. Sidekiq for example.
track_url = "http://soundcloud.com/forss/flickermood"

# We call SoundCloud API to resolve track url
track = client.get('/resolve', url: track_url)

# If track is not downloadable, abort the process
unless track["downloadable"]
  puts "You can't download this track!"
  exit 1
end

# We take track id, and we use that to name our local file
track_id = track.id
track_filename = "%s.aif" % track_id.to_s
download_url = "%s?client_id=%s" % [track.download_url, ENV.fetch("SC_CLIENT_ID")]

File.open(track_filename, "wb") do |saved_file|
  open(download_url, allow_redirections: :all) do |read_file|
    saved_file.write(read_file.read)
  end
end

puts "Your track was saved to: #{track_filename}"
