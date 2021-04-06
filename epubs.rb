require "gepub"
require "sinatra"

class Hivemind < Sinatra::Base
  get "/epubs" do
    @epubs = EPub.all
    erb :"epubs/index"
  end

  get "/epubs/upload" do
    erb :"epubs/upload"
  end

  post "/epubs/upload" do
    tf = params[:epub][:tempfile]

    book = nil
    File.open(tf) do |f|
      book = GEPUB::Book.parse(f)
    end

    epub = EPub.create(
      title: book.title.content,
      creator: book.creator.content,
      publisher: book.publisher.content,
      uploader: current_user,
      epub: File.read(tf),
    )

    redirect "/epubs/#{epub.id}"
  end

  get "/epubs/:epub_id" do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    erb :"epubs/show"
  end
end

class EPub < Sequel::Model
  def parsed
    GEPUB::Book.parse StringIO.new(self.epub.to_s)
  end
end
