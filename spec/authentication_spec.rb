require_relative "spec_helper"

RSpec.describe "authentication" do
  describe "unauthenticated pages" do
    it "renders the page" do
      get "/login"
      expect(last_response).to be_ok
      expect(last_response.body).to match(%r{button.+Login})
    end
  end

  describe "authenticated pages" do
    it "redirects to the login page" do
      get "/"
      expect(last_response).to be_redirect

      follow_redirect!

      expect(last_response).not_to be_redirect
      expect(last_response).to be_ok
      expect(last_response.body).to match(%r{button.+Login})
    end
  end
end
