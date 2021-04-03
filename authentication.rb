require "sinatra"

class Hivemind < Sinatra::Base
  UNAUTHENTICATED_PATHS = Regexp.union(
    %r(^/login$), %r(^/logout$),
  )

  get "/login" do
    erb :"authentication/login"
  end

  post "/login" do
    username = params[:username]
    password = params[:password]

    user = User.find(username: username)

    return erb :"authentication/login" if user.nil?
    return erb :"authentication/login" unless user.authenticate(password)

    session[:current_user] = username
    redirect "/"
  end

  get "/logout" do
    session.delete :current_user
    redirect "/"
  end

  before do
    return redirect("/login") unless
    request.path_info.match?(UNAUTHENTICATED_PATHS) || current_user
  end

  helpers do
    def current_user
      username = session[:current_user]
      return nil if username.nil? || username.empty?
      User.find(username: username)
    end

    def csrf_token_hidden_input
      %(<input type="hidden" name="authenticity_token" value="#{env["rack.session"][:csrf]}">)
    end
  end
end
