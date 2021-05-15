require_relative "spec_helper"

RSpec.describe "epubs" do
  before(:all) { ensure_logged_in }

  describe "upload" do
    it "renders the page" do
      get "/epubs/upload"
      expect(last_response).to be_ok
    end

    it "uploads an ebook" do
      upload_pride_and_prejudice

      expect(last_response).to be_ok
      expect(last_response.body).to match(/pride and prejudice/i)
      expect(last_response.body).to match(/jane austen/i)
    end

    describe "pride and prejudice" do
      before(:all) do
        upload_pride_and_prejudice

        epub_id = last_request.url[%r{/epubs/(\d+)}, 1].to_i
        @epub = EPub.find(id: epub_id)
      end

      it "can be parsed" do
        expect { @epub.parsed }.not_to raise_exception
      end

      it "is readable" do
        get "/epubs/#{@epub.id}/read"

        expect(last_response).to be_redirect
        follow_redirect!

        expect(last_request.url).to match(/href/).and match(/#{@epub.id}/)
        expect(last_response.body).to match(/iframe/)
      end
    end

    describe "halma" do
      before(:all) do
        upload_halma

        epub_id = last_request.url[%r{/epubs/(\d+)}, 1].to_i
        @epub = EPub.find(id: epub_id)
      end

      it "can be parsed" do
        expect { @epub.parsed }.not_to raise_exception
      end

      it "is readable" do
        get "/epubs/#{@epub.id}/read"

        expect(last_response).to be_redirect
        follow_redirect!

        expect(last_request.url).to match(/href/).and match(/#{@epub.id}/)
        expect(last_response.body).to match(/iframe/)
      end

      it "has a cover" do
        expect(@epub.cover?).to be_truthy
      end

      it "has a table of contents" do
        expect(@epub.table_of_contents?).to be_truthy
      end

      it "has some images" do
        expect(@epub.images).not_to be_empty
      end
    end
  end
end

def upload_pride_and_prejudice
  upload_epub("pride-and-prejudice.epub")
end

def upload_halma
  upload_epub("halma.epub")
end

def upload_epub(path)
  ensure_logged_in

  get "/epubs/upload"
  expect(last_response).to be_ok

  post "/epubs/upload", {
    "epub" => Rack::Test::UploadedFile.new(fixture_path(path)),
    "authenticity_token" => token_from_current_page,
  }

  expect(last_response).to be_redirect
  follow_redirect!
end
