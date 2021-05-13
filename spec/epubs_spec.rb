require_relative "spec_helper"

RSpec.describe "epubs" do
  before(:each) { login }

  describe "upload" do
    it "renders the page" do
      get "/epubs/upload"
      expect(last_response).to be_ok
    end

    it "uploads an ebook" do
      get "/epubs/upload"
      expect(last_response).to be_ok

      post "/epubs/upload", {
        "epub" => Rack::Test::UploadedFile.new(fixture_path("pride-and-prejudice.epub")),
        "authenticity_token" => token_from_current_page,
      }

      expect(last_response).to be_redirect
      follow_redirect!

      expect(last_response).to be_ok
      expect(last_response.body).to match(/pride and prejudice/i)
      expect(last_response.body).to match(/jane austen/i)
    end
  end
end
