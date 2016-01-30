#! /usr/local/bin/ruby

require 'webrick'
require "json"
require "./client_player"
require "gosu"
require "./message.rb"

root = File.expand_path './'
server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root

trap 'INT' do server.shutdown end

players = {}

def make_hash(players, id)
  return_hash = {}
  players.each do |key, player|
    if key != id
      return_hash[key] = player.to_json
    end
  end
  return_hash
end

server.mount_proc '/' do |req, res|
  req = Request.new.from_json!(req.body)

  puts req.inspect

  response = Response.new
  response.allowed = false
  res.body = response.to_json
end

server.start