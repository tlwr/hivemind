require "sinatra"

class Hivemind < Sinatra::Base
  get "/bookmarks" do
    @bookmarks = current_user.epub_bookmarks
    erb :"bookmarks/index"
  end

  post "/bookmarks/:id/delete" do
    current_user.epub_bookmarks.find(id: params[:id])&.first&.delete
    redirect "/bookmarks"
  end
end
