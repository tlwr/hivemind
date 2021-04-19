require "rake"

require_relative "hivemind"

desc "Extract covers from EPubs and stores them in the database as base64 images"
task :epub_extract_covers do
  EPub.all.select(&:cover?).each do |epub|
    puts epub.title

    cover = epub.parsed.item_by_href(epub.cover.href)
    epub.cover_blob = cover.content
    epub.cover_media_type = cover.media_type
    epub.save
  end
end
