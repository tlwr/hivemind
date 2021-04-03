require "sinatra"

require "rack/protection"

class Hivemind < Sinatra::Base
  enable :sessions

  use Rack::Protection
  use Rack::Protection::AuthenticityToken
end

require_relative "db"

require_relative "authentication"
require_relative "pages"
