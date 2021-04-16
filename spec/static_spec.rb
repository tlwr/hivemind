require_relative "spec_helper"

RSpec.describe "static" do
  it "serves a static text file" do
    get "/robots.txt"
    expect(last_response).to be_ok
  end
end
