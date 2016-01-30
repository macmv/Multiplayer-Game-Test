
class JsonMessage
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

class Request < JsonMessage
  attr_accessor :client,:action,:options
end

class Response < JsonMessage
  attr_accessor :allowed,:msg
end