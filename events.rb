require "sinatra"

class Hivemind < Sinatra::Base
  get "/events" do
    @latest = Event.last(25)
    erb :"events/index"
  end

  get "/activity" do
    redirect "/events"
  end
end

class Event < Sequel::Model
  def nice
    case kind.to_sym
    when :uploaded_epub
      epub = EPub.find(id: metadata[:epub_id])
      user = User.find(id: metadata[:user_id])

      user_link = %(<a class="underline hover:text-indigo-500" href="/@#{user.username}">@#{user.username}</a>)
      epub_link = %(<a class="underline hover:text-indigo-500" href="/epubs/#{epub.id}">#{epub.title}</a>)

      "#{user_link} uploaded #{epub_link}"
    end
  end

  def relevant?
    case kind.to_sym
    when :uploaded_epub
      epub.nil? || user.nil? ? false : true
    end
  end

  def epub
    @epub ||= EPub.find(id: metadata[:epub_id])
  end

  def user
    @user ||= User.find(id: metadata[:user_id])
  end
end
