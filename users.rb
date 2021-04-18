require "sinatra"

class Hivemind < Sinatra::Base
  get "/me" do
    @user = current_user
    erb :"users/show"
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
