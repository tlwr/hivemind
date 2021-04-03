require_relative "spec_helper"

RSpec.describe "users" do
  describe "passwords" do
    let(:un) { "rspec" }
    let(:pw) { "this-is-a-long-password" }

    it "validates passwords" do
      u = User.new(username: un)
      expect(u.valid?).to be false

      u.password = pw
      expect(u.valid?).to be false

      u.password_confirmation = pw
      expect(u.valid?).to be true
    end

    it "persists" do
      u = User.new(username: un)
      u.password = pw
      u.password_confirmation = pw
      u.save

      u = User.find(username: un)
      expect(u.password).to be_nil
      expect(u.authenticate(pw)).to eq(u)
    end
  end

  describe "logging in" do
    let!(:authenticity_token) do
      get "/login"
      last_response.body.match(/authenticity_token.+value="([^"]+)"/)[1]
    end

    context "when the user does not exist" do
      it "serves the login page" do
        post "/login", {
          "username" => "foo",
          "password" => "bar",
          "authenticity_token" => authenticity_token,
        }

        expect(last_response).not_to be_redirect
        expect(last_response).to be_ok
        expect(last_response.body).to match(%r(button.+login))
      end
    end

    context "when the user exists" do
      un = "logging-in"
      pw = "this-is-a-long-password"

      before(:all) do
        u = User.new(username: un)
        u.password = pw
        u.password_confirmation = pw
        u.save
      end

      context "when the password is incorrect" do
        it "serves the login page" do
          post "/login", {
            "username" => un,
            "password" => "",
            "authenticity_token" => authenticity_token,
          }

          expect(last_response).not_to be_redirect
          expect(last_response).to be_ok
          expect(last_response.body).to match(%r(button.+login))
        end
      end

      context "when the password is correct" do
        it "redirects to the index page" do
          post "/login", {
            "username" => un,
            "password" => pw,
            "authenticity_token" => authenticity_token,
          }

          expect(last_response).to be_redirect

          follow_redirect!

          expect(last_response).not_to be_redirect
          expect(last_response).to be_ok
          expect(last_response.body).to match(%r(index))
        end
      end
    end
  end
end
