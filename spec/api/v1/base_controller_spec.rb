require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe "API Routes", type: :request do
  describe "Error handling" do
    it "returns 404 merchant" do
      get "/api/v1/merchants/2412104"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 item" do
      get "/api/v1/items/9123912"
      expect(response).to have_http_status(:not_found)
    end
  end
end