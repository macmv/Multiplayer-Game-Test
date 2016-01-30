#! /usr/local/bin/ruby

require 'webrick'
require "json"
require "./client_player"
require "gosu"

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
  puts req.body.class
  client = ClientPlayer.new.from_json!(req.body)
  data = JSON.parse(req.body)
  puts "data \\/"
  puts data.inspect
  puts "///////////////////////////////"
  puts client
  puts client.inspect
  puts client.class
  puts "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  id = data["@id"].to_i
  x = data["@x"].to_i
  y = data["@y"].to_i
  if players[id] != nil
    if data["@quiting"] == "true"
      players.delete id.to_i
    else
      players[id].x = x
      players[id].y = y
    end
  else
    players[id] = ClientPlayer.new
    players[id].x = x
    players[id].y = y
  end
  res.body = make_hash(players, id).to_json
  puts players
end

server.start