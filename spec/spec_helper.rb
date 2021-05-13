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

def fixture_path(path)
  File.expand_path(File.join(File.dirname(__FILE__), "fixtures", path))
end

def token_from_current_page
  last_response.body.match(/authenticity_token.+value="([^"]+)"/)[1]
end

def login
  get "/login"

  post "/login", {
    "username" => "test",
    "password" => "test-user-password",
    "authenticity_token" => token_from_current_page,
  }

  expect(last_response).to be_redirect
  follow_redirect!

  expect(last_response).to be_redirect
  follow_redirect!

  expect(last_response).to be_ok
end
