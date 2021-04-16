require_relative "spec_helper"

RSpec.describe "static" do
  it "serves css" do
    get "/style.css"
    expect(last_response).to be_ok
  end
end
