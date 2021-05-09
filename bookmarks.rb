require "sinatra"

class Hivemind < Sinatra::Base
  get "/bookmarks" do
    @bookmarks = current_user.epub_bookmarks
    erb :"bookmarks/index"
  end

  post "/bookmarks/:id/delete" do
    current_user.epub_bookmarks.find { _1.id == params[:id].to_i }&.delete
    redirect "/bookmarks"
  end
end
