#! /usr/local/bin/ruby

require "http"
require "json"
require "./client_player.rb"

player = ClientPlayer.new

#j = player.to_json

puts HTTP.post("http://localhost:8000/", :json => player)

HTTP.post("http://localhost:8000/", :json => @player)