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

    title = book&.title&.content || "Unknown title"
    creator = book&.creator&.content || "Unknown creator"
    publisher = book&.publisher&.content || "Unknown publisher"

    epub = EPub.create(
      title: title, creator: creator, publisher: publisher,
      uploader: current_user,
      epub: File.read(tf),
    )

    Event.record(:uploaded_epub, user_id: current_user.id, epub_id: epub.id)

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

    redirect "/epubs/#{@epub.id}/href/#{@epub.first_readable.href}?read#read-start"
  end

  get %r(/epubs/(?<epub_id>\d+)/href/(?<href>.*)) do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    @item = @epub.parsed.item_by_href(params[:href])

    if params.key? :read
      erb :"epubs/read"
    else
      content_type @item.media_type
      @item.content
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

  def images
    parsed.items.values.select { _1.media_type =~ /jpeg/i || _1.media_type =~ /png/i }
  end

  def prev_href(item)
    chapters.take_while { _1.id != item }.last&.href
  end

  def next_href(item)
    chapters.drop_while { _1.id != item }.drop(1).first&.href
  end

  def cover_href
    href = images.select { |i| i.id =~ /cover/i }.first&.href
    href && href_path(href)
  end

  def first_readable
    chapters.find { |v| v.id =~ /cover/i } ||
    chapters.find { |v| v.id =~ /toc/i } ||
    chapters.find { |v| v.id =~ /contents/i } ||
    chapters.find { |v| v.id =~ /preface/i } ||
    chapters.find { |v| v.id =~ /foreword/i } ||
    chapters.find { |v| v.id =~ /chapter/i } ||
    chapters.first
  end
end
