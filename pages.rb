require "sinatra"

class Hivemind < Sinatra::Base
  get "/" do
    redirect "/epubs"
  end
end
