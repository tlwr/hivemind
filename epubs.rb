require "gepub"
require "sinatra"

class Hivemind < Sinatra::Base
  get "/epubs" do
    @author = params[:author]

    @epubs = if (@author || "").empty?
               EPub.all
             else
               EPub.where(creator: @author).all
             end

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

    if epub.cover?
      epub.cover_blob = epub.cover.content
      epub.cover_media_type = epub.cover.media_type
      epub.save
    end

    redirect "/epubs/#{epub.id}"
  end

  get "/epubs/random" do
    redirect "/epubs/#{EPub.select(&:id).map(&:id).shuffle.first}"
  end

  get "/epubs/:epub_id" do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    c_ids = @epub.collections.map(&:id)
    @collections = Collection.all
    @potential_collections = @collections.reject { |c| c_ids.include? c.id }

    erb :"epubs/show"
  end

  get "/epubs/:epub_id/cover" do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    raise Sinatra::NotFound if @epub.cover_blob.nil? || @epub.cover_blob.empty?

    cache_control :public, :max_age => 86400
    content_type @epub.cover_media_type
    @epub.cover_blob
  end

  post "/epubs/:epub_id/status" do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    status = params[:status]&.gsub("-", "_")&.to_sym
    raise Sinatra::BadRequest if status.nil?

    case status
    when :wants_to_read
      current_user.wants_to_read_epub!(@epub)
    when :is_reading
      current_user.is_reading_epub!(@epub)
    when :has_read
      current_user.has_read_epub!(@epub)
    when :clear
      current_user.clear_epub_status!(@epub)
    end

    redirect "/epubs/#{@epub.id}"
  end

  post "/epubs/:epub_id/bookmark" do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    href = params[:href]
    raise Sinatra::BadRequest if href.nil?

    current_user.bookmark_epub!(epub_id=@epub.id, href=href)

    redirect @epub.href_path(href) + "?read#read-start"
  end

  get "/epubs/:epub_id/read" do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    redirect "/epubs/#{@epub.id}/href/#{@epub.first_readable.href}?read#read-start"
  end

  get %r{/epubs/(?<epub_id>\d+)/href/(?<href>.*)} do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    @item = @epub.parsed.item_by_href(params[:href])

    if params.key? :read
      @href = params[:href]
      @show_bookmark_button = current_user.bookmark_for_epub(@epub) != @href
      erb :"epubs/read"
    else
      content_type @item.media_type
      @item.content
    end
  end

  post "/epubs/:epub_id/collections" do
    @epub = EPub.find(id: params[:epub_id])
    raise Sinatra::NotFound if @epub.nil?

    @collection = Collection.find(id: params[:collection_id])
    raise Sinatra::NotFound if @collection.nil?

    @collection.add_epub(@epub)

    redirect "/epubs/#{@epub.id}"
  end
end

class EPub < Sequel::Model
  def parsed
    @parsed ||= GEPUB::Book.parse StringIO.new(epub.to_s)
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

  def cover
    cover_from_id = images.find { |i| i.id =~ /cover/i }
    cover_from_href = images.find { |i| i.href =~ /cover/i }

    cover_from_id || cover_from_href
  end

  def cover?
    !cover.nil?
  end

  def cover_href
    return nil if cover_blob.nil? || cover_blob.empty?
    "/epubs/#{id}/cover"
  end

  def table_of_contents
    chapters.find { |c| c.id =~ /contents/i } ||
      chapters.find { |c| c.id =~ /toc/i } ||
      chapters.find { |c| c.id =~ /table/i } ||
      chapters.find { |c| c.id =~ /content/i }
  end

  def table_of_contents?
    !table_of_contents.nil?
  end

  def first_readable
    chapters.find { |v| v.id =~ /cover/i } ||
      chapters.find { |v| v.id =~ /toc/i } ||
      chapters.find { |v| v.id =~ /contents/i } ||
      chapters.find { |v| v.id =~ /preface/i } ||
      chapters.find { |v| v.id =~ /foreword/i } ||
      chapters.find { |v| v.id =~ /chapter/i } ||
      chapters.find { |v| v.id =~ /content/i } ||
      chapters.first
  end
end
