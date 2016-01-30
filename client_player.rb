require 'json'

class ClientPlayer

  attr_accessor :x, :y

  def initialize
    @x = 50
    @y = 50
    @id = rand
    @color = Gosu::Color.new(rand(200) + 56, rand(200) + 56, rand(200) + 56)
  end

  def draw
    Gosu.draw_rect(@x, @y, @x + 20, @y + 40, 0xff_00ff00)
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