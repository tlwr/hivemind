require "sinatra"

class Hivemind < Sinatra::Base
  get "/me" do
    redirect current_user.show_path
  end

  get %r(/@(?<username>[^/]+)) do
    @user = User.find(username: params[:username])
    raise Sinatra::NotFound if @user.nil?
    erb :"users/show"
  end
end

class User < Sequel::Model
  def show_path
    "/@#{username}"
  end
end

class User < Sequel::Model
  def status_for_epub(epub)
    epub_id = epub.is_a?(Numeric) ? epub : epub.id
    EPubUserStatus.find(e_pub_id: epub_id, user_id: id)&.status&.to_sym
  end

  def wants_to_read_epub!(epub)
    epub_id = epub.is_a?(Numeric) ? epub : epub.id

    EPubUserStatus.update_or_create(
      { user_id: id, e_pub_id: epub_id },
      { status: "wants_to_read" },
    )
  end

  def is_reading_epub!(epub)
    epub_id = epub.is_a?(Numeric) ? epub : epub.id

    EPubUserStatus.update_or_create(
      { user_id: id, e_pub_id: epub_id },
      { status: "is_reading" },
    )
  end

  def has_read_epub!(epub)
    epub_id = epub.is_a?(Numeric) ? epub : epub.id

    EPubUserStatus.update_or_create(
      { user_id: id, e_pub_id: epub_id },
      { status: "has_read" },
    )

    Event.record(:read_epub, user_id: id, epub_id: epub_id)
  end

  def clear_epub_status!(epub)
    epub_id = epub.is_a?(Numeric) ? epub : epub.id

    EPubUserStatus.where(e_pub_id: epub.id, user_id: id)&.delete
  end

  def bookmark_for_epub(epub)
    epub_id = epub.is_a?(Numeric) ? epub : epub.id
    EPubUserBookmark.find(e_pub_id: epub_id, user_id: id)&.href
  end

  def bookmark_epub!(epub, href)
    epub_id = epub.is_a?(Numeric) ? epub : epub.id

    EPubUserBookmark.update_or_create(
      { user_id: id, e_pub_id: epub_id },
      { href: href },
    )
  end
end
