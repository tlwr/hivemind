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

  get "/epubs/:epub_id/read" do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    redirect "/epubs/#{@epub.id}/href/#{@epub.parsed.items.values.first.href}"
  end

  get %r(/epubs/(?<epub_id>\d+)/href/(?<href>.*)) do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    @item = @epub.parsed.item_by_href(params[:href])

    if @item.media_type =~ /image/ || @item.media_type =~ /css/
      content_type @item.media_type
      @item.content
    else
      erb :"epubs/read"
    end
  end
end

class EPub < Sequel::Model
  def parsed
    GEPUB::Book.parse StringIO.new(self.epub.to_s)
  end

  def href_path(href)
    "/epubs/#{id}/href/#{href}"
  end

  def chapters
    parsed.items.values.select { _1.media_type =~ /html/ }
  end

  def prev_href(item)
    chapters.take_while { _1.id != item }.last&.href
  end

  def next_href(item)
    chapters.drop_while { _1.id != item }.drop(1).first&.href
  end
end
