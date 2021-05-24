require_relative "spec_helper"

RSpec.describe "epubs" do
  before(:all) { ensure_logged_in }

  describe "upload" do
    it "renders the page" do
      get "/epubs/upload"
      expect(last_response).to be_ok
    end

    it "uploads an ebook" do
      ensure_pride_and_prejudice_uploaded

      expect(last_response).to be_ok
      expect(last_response.body).to match(/pride and prejudice/i)
      expect(last_response.body).to match(/jane austen/i)
    end

    describe "pride and prejudice" do
      before(:all) { @epub = ensure_pride_and_prejudice_uploaded }

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
      before(:all) { @epub = ensure_halma_uploaded }

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
        expect(@epub.cover?).not_to be_nil
      end

      it "has a table of contents" do
        expect(@epub.table_of_contents).not_to be_nil
      end

      it "has some images" do
        expect(@epub.images).not_to be_empty
      end
    end
  end






end
