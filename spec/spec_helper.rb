ENV["RACK_ENV"] = "test"

require_relative "../hivemind"
require "rspec"
require "rack/test"

RSpec.configure do |c|
  c.include Rack::Test::Methods
end

def app
  Hivemind.new
end
