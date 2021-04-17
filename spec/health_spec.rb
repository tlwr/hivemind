require_relative "spec_helper"

RSpec.describe "health" do
  it "reports health status" do
    get "/health"
    expect(last_response).to be_ok
  end
end
