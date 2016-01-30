#! /usr/local/bin/ruby

require "http"
require "json"
require "./message.rb"

req = Request.new
req.client = '12345'
req.action = "move"
req.options = {"x" => 1, "y" => 2}

#puts req.to_json

response = HTTP.post("http://localhost:8000/", :json => req)

puts Response.new.from_json!(response.body).inspect