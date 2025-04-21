require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe "Item Merchants API", type: :request do
  def expect_successful_response(status = 200)
    expect(response).to be_successful
    expect(response.status).to eq(status)
  end
  
  def expect_error_response(status = 400)
    expect(response).not_to be_successful
    expect(response.status).to eq(status)
    parsed_response = JSON.parse(response.body, symbolize_names: true)
    expect(parsed_response).to have_key(:message)
    expect(parsed_response).to have_key(:errors)
  end
  
  def parse_response
    JSON.parse(response.body, symbolize_names: true)
  end
  
  def validate_merchant(merchant)
    expect(merchant).to have_key(:id)
    expect(merchant).to have_key(:type)
    expect(merchant).to have_key(:attributes)
    expect(merchant[:attributes]).to have_key(:name)
  end
  
  describe "GET /api/v1/items/:item_id/merchant" do
    before do
      @merchant = Merchant.create!(name: "Test Merchant")
      @item = Item.create!(
        name: "Sample Item", 
        description: "A sample item for testing (;", 
        unit_price: 15.99, 
        merchant: @merchant
      )
    end
    
    describe "happy path" do
      it "retrieves the merchant for an item" do
        get "/api/v1/items/#{@item.id}/merchant"
        
        expect_successful_response
        
        merchant_data = parse_response
        expect(merchant_data).to have_key(:data)
        
        merchant = merchant_data[:data]
        validate_merchant(merchant)
        
        expect(merchant[:id].to_i).to eq(@merchant.id)
        expect(merchant[:attributes][:name]).to eq(@merchant.name)
      end
    end
    
    describe "sad path" do
      it "item doesn't exist" do
        get "/api/v1/items/2848248/merchant"
        
        expect_error_response(404)
      end
      
      it "item ID is invalid" do
        get "/api/v1/items/invalid_id/merchant"
        
        expect_error_response(404)
      end
    end
  end
end