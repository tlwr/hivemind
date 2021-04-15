require "sinatra"

require "rack/protection"

class Hivemind < Sinatra::Base
  enable :sessions
  set :session_secret, "reuse-dev-sessions" if ENV["RACK_ENV"] == "development"

  set :static, true
  set :public_folder, Proc.new { File.join(root, "static") }

  use Rack::Protection
  use Rack::Protection::AuthenticityToken
end

require_relative "db"

require_relative "authentication"
require_relative "epubs"
require_relative "pages"
