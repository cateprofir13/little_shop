
require 'rails_helper'
describe "Merchant Items", type: :request do
  it "returns all items for a given merchant" do
    merchant = Merchant.create!(name: "Alice Wonder")
    item1 = merchant.items.create!(name: "Item One", description: "desc", unit_price: 10.0)
    item2 = merchant.items.create!(name: "Item Two", description: "desc", unit_price: 20.0)

    get "/api/v1/merchants/#{merchant.id}/items"

    expect(response).to be_successful

    parsed = JSON.parse(response.body, symbolize_names: true)
    expect(parsed).to have_key(:data)
    expect(parsed[:data].length).to eq(2)

    parsed[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:type]).to eq("item")
      expect(item).to have_key(:attributes)
      expect(item[:attributes][:name]).to be_a(String)
    end
  end
  
  it "returns a 404 if the merchant is not found" do
    get "/api/v1/merchants/999999/items" 
  
    expect(response.status).to eq(404)
  
    parsed = JSON.parse(response.body, symbolize_names: true)
    expect(parsed).to have_key(:errors)
    expect(parsed[:errors].first).to match(/Couldn't find Merchant/)
  end

end