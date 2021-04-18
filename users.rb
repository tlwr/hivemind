require "sinatra"

class Hivemind < Sinatra::Base
  get "/me" do
    @user = current_user
    erb :"users/show"
  end
end
