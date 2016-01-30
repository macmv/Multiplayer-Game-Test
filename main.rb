#! /usr/local/bin/ruby

require "gosu"
require "colorize"
require "trollop"
require "json"
require "http"

$opts = Trollop::options do
  opt :fullscreen, "Use fullscreen"
end

module MultiplayerTest

WIDTH = 800
HEIGHT = 600

private

class OtherPlayer

  attr_accessor :x, :y

  def initialize(x, y)
    @x = x.to_i
    @y = y.to_i
    @color = Gosu::Color.new(0, 256, 0)
  end

  def draw
    Gosu.draw_rect(@x, @y, 20, 40, @color)
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

class Player

  attr_reader :id, :x, :y

  def initialize
    @x = WIDTH / 2
    @y = HEIGHT / 3
    @speed = 5
    @color = Gosu::Color.new(rand(200) + 56, rand(200) + 56, rand(200) + 56)
    @id = rand(10000000000)
  end

  def draw
    Gosu.draw_rect(@x, @y, 20, 40, @color)
  end

  def up
    @y -= @speed
    @y += @speed if @y < 0
  end

  def down
    @y += @speed
    @y -= @speed if @y + 40 > HEIGHT
  end

  def right
    @x += @speed
    @x -= @speed if @x + 20 > WIDTH
  end

  def left
    @x -= @speed
    @x += @speed if @x < 0
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

public

class Screen < Gosu::Window

  def initialize
    super 800, 600, $opts[:fullscreen]
    self.caption = "Multiplayer Test"
    @player = Player.new
    @players = []
  end

  def send_get_data
    #begin
      tmp_players = JSON.parse(HTTP.post("http://localhost:8000/", :json => @player))
      new_players = []
      tmp_players.each do |key, index|
        #puts index
        new_players.push OtherPlayer.new index["@x"].to_i, index["@y"].to_i#, index["@color"]
      end
      return new_players

    #rescue
      #puts "socket ERR".red
    #end
    ""
  end

  def to_arr(players)
    new_arr = []
    if players.class == String
      players.split(" ").each do |item|
        new_arr.push OtherPlayer.new item[0], item[1]
      end
    else
      new_arr = players
      #puts "server response ERR".red
    end
    new_arr
  end

  def draw
    Gosu.draw_rect(0, 0, WIDTH, HEIGHT, 0xaa_00aadd)
    @player.draw
    @players.each do |player|
      player.draw
    end
  end

  def update
    players = send_get_data
    #puts players.inspect
    @players = to_arr players
    puts @players.inspect
    if Gosu::button_down?(Gosu::KbUp) || Gosu::button_down?(Gosu::KbW)
      @player.up
    elsif Gosu::button_down?(Gosu::KbDown) || Gosu::button_down?(Gosu::KbS)
      @player.down
    end
    if Gosu::button_down?(Gosu::KbLeft) || Gosu::button_down?(Gosu::KbA)
      @player.left
    elsif Gosu::button_down?(Gosu::KbRight) || Gosu::button_down?(Gosu::KbD)
      @player.right
    end
  end

end

end

MultiplayerTest::Screen.new.show
HTTP.post("http://localhost:8000/", :json => {"@quiting" => "true"})