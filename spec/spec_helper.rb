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

  @logged_in = true
end

def ensure_logged_in
  login unless @logged_in
end

def upload_pride_and_prejudice
  upload_epub("pride-and-prejudice.epub")
end

def upload_halma
  upload_epub("halma.epub")
end

def upload_epub(path)
  ensure_logged_in

  get "/epubs/upload"
  expect(last_response).to be_ok

  post "/epubs/upload", {
    "epub" => Rack::Test::UploadedFile.new(fixture_path(path)),
    "authenticity_token" => token_from_current_page,
  }

  expect(last_response).to be_redirect
  follow_redirect!

  epub_id = last_request.url[%r{/epubs/(\d+)}, 1].to_i
  EPub.find(id: epub_id)
end

def ensure_halma_uploaded
  EPub.find(title: "Halma") || upload_halma
end

def ensure_pride_and_prejudice_uploaded
  EPub.find(title: "Pride and Prejudice") || upload_pride_and_prejudice
end
