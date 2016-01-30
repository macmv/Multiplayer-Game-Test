#! /usr/local/bin/ruby

require "socket"
require "set"
require "thread"
require "colorize"
require "webrick"

root = File.expand_path './'
server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root

def players_to_str(players, id)
  return_val = ""
  players.each do |key, player|
    if key != id
      return_val += "#{player.x}-#{player.y} "
    end
  end
  return_val
end

class Player

  attr_reader :x, :y, :id, :socket

  def initialize(x, y, id, socket)
    @x = x.to_i
    @y = y.to_i
    @id = id
    @socket = socket
  end

  def set(x, y)
    @x = x
    @y = y
  end

  def to_json
    hash = {}
    self.instance_variables.each do |var|
      hash[var] = self.instance_variable_get var
    end
    hash.to_json
  end
  
  def from_json!(string)
    JSON.load(string).each do |var, val|
      self.instance_variable_set var, val
    end
    return self
  end

end

players = {}

semaphore = Mutex.new

id_arr = []

new_id_num = 0

server.mount_proc '/' do |req, res|
  new_client = req
  puts
  data = JSON.parse(req.body)
  new_id = data["@id"].to_i
  new_x = data["@x"].to_i
  new_y = data["@y"].to_i
  semaphore.synchronize do
    players[new_id_num] = Player.new new_x, new_y, new_id, new_client
  end
  semaphore.synchronize do
    puts "nil"
    puts new_id_num
    id_arr.push new_id
  end
  #puts "hi"
  Thread.new do
    my_id = new_id_num - 1
    while true
      puts "////////////////".green
      semaphore.synchronize do
        puts "semaphore"
        puts "players = #{players.inspect}"
        socket = players[id_arr[my_id]].socket
        puts "semaphore 2"
      end
      begin
        semaphore.synchronize do
          tmp_players = players
        end
        data = socket.gets
        socket.puts players_to_str(tmp_players, id)
        if data.class == String
          data = data.split " "
          id = data[0]
          x = data[1]
          y = data[2]
          if new_players.has_key? id
            if x == "quit"
              new_players.delete id
              socket.puts "quit"
            else
              new_players[id].set x, y
              socket.puts players_to_str(tmp_players, id)
            end
          else
            socket.puts ""
          end
        else
          socket.puts ""
        end
      rescue
        puts "leave"
      end
      semaphore.synchronize do
        players = new_players
      end
    end
  end
  new_id_num += 1
end

server.start

#Thread.new do
#  while true
#    puts "////////////////////////////////////////////////////////////////////////////////".green.bold
#    client = server.accept
#    puts "////////////////////////////////////////////////////////////////////////////////".red.bold 
#    id = client.gets
#    semaphore.synchronize do
#      players[id] = Player.new 0, 0, id, client
#      client.puts players
#    end
#  end
#end

#while true
#  tmp_players = nil
#  semaphore.synchronize do
#    tmp_players = players
#  end
#  new_players = tmp_players
#  puts tmp_players.length
#  tmp_players.each do |id, player|
#    socket = player.socket
#    begin
#      data = socket.gets
#      socket.puts players_to_str(players, id)
#      if data.class == String
#        data = data.split " "
#        id = data[0]
#        x = data[1]
#        y = data[2]
#        if new_players.has_key? id
#          if x == "quit"
#            new_players.delete id
#            socket.puts "quit"
#          else
#            new_players[id].set x, y
#            socket.puts players_to_str(players, id)
#          end
#        else
#          socket.puts ""
#        end
#      else
#        socket.puts ""
#      end
#    rescue
#      puts "leave"
#      new_players.delete id
#    end
#  end
#  semaphore.synchronize do
#    players = new_players
#  end
#end