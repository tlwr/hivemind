require_relative "spec_helper"

RSpec.describe "pages" do
  before(:all) { ensure_logged_in }

  describe "index" do
    it "redirects to /epubs" do
      get "/"
      expect(last_response).to be_redirect

      follow_redirect!

      expect(last_request.url).to match(%r{/epubs$})
    end
  end

  describe "authors" do
    before(:all) do
      ensure_halma_uploaded
      ensure_pride_and_prejudice_uploaded
    end

    it "lists all the authors" do
      get "/authors"
      expect(last_response).to be_ok

      expect(last_response.body).to match(/benito/i)
      expect(last_response.body).to match(/jane austen/i)
    end
  end
end
