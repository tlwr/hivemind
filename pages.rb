require "sinatra"

class Hivemind < Sinatra::Base
  get "/" do
    erb :"pages/index"
  end
end
