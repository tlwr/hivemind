require "sinatra"

class Hivemind < Sinatra::Base
  get "/me" do
    erb :"users/me"
  end
end
