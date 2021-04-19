require "sinatra"

class Hivemind < Sinatra::Base
  get "/collections" do
    @collections = Collection.all
    erb :"collections/index"
  end

  get "/collections/new" do
    erb :"collections/new"
  end

  post "/collections/new" do
    title = params[:title]
    raise Sinatra::BadRequest if title.nil? || !title.match?(/[-,._+a-zA-Z0-9 ]{2,32}/)

    col = Collection.create(title: title, creator: current_user)

    Event.record(:created_collection, user_id: current_user.id, collection_id: col.id)

    redirect "/collections/#{col.id}"
  end

  get "/collections/:collection_id" do
    @collection = Collection.find(id: params[:collection_id])
    raise Sinatra::NotFound if @collection.nil?

    erb :"collections/show"
  end
end
