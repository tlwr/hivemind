require "sinatra"

class Hivemind < Sinatra::Base
  get "/bookmarks" do
    @bookmarks = current_user.epub_bookmarks
    erb :"bookmarks/index"
  end
end
