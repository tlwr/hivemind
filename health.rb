require "sinatra"

class Hivemind < Sinatra::Base
  get "/health" do
    "ok"
  end
end
