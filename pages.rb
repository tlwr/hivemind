require "sinatra"

class Hivemind < Sinatra::Base
  get "/" do
    redirect "/epubs"
  end

  get "/authors" do
    @authors = EPub.select(:creator).map(&:creator).uniq
    erb :"pages/authors"
  end
end
