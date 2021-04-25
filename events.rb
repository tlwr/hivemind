require "sinatra"

class Hivemind < Sinatra::Base
  get "/activity" do
    @latest = Event.last(25)
    erb :"events/index"
  end
end

class Event < Sequel::Model
  def nice
    case kind.to_sym
    when :uploaded_epub
      user_link = %(<a class="underline hover:text-indigo-500" href="/@#{user.username}">@#{user.username}</a>)
      epub_link = %(<a class="underline hover:text-indigo-500" href="/epubs/#{epub.id}">#{epub.title}</a>)

      "#{user_link} uploaded #{epub_link}"
    when :created_collection
      user_link = %(<a class="underline hover:text-indigo-500" href="/@#{user.username}">@#{user.username}</a>)
      collection_link = %(<a class="underline hover:text-indigo-500" href="/collections/#{collection.id}">#{collection.title}</a>)

      "#{user_link} created #{collection_link}"
    when :read_epub
      user_link = %(<a class="underline hover:text-indigo-500" href="/@#{user.username}">@#{user.username}</a>)
      epub_link = %(<a class="underline hover:text-indigo-500" href="/epubs/#{epub.id}">#{epub.title}</a>)
      "#{user_link} marked #{epub_link} as read"
    end
  end

  def relevant?
    case kind.to_sym
    when :uploaded_epub
      epub.nil? || user.nil? ? false : true
    when :created_collection
      collection.nil? || user.nil? ? false : true
    when :read_epub
      epub.nil? || user.nil? ? false : true
    end
  end

  def epub
    @epub ||= EPub.find(id: metadata[:epub_id])
  end

  def user
    @user ||= User.find(id: metadata[:user_id])
  end

  def collection
    @collection ||= Collection.find(id: metadata[:collection_id])
  end
end
