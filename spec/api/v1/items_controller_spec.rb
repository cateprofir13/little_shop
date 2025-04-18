require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe "Items API", type: :request do
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
  
  def validate_item_structure(item)
    expect(item).to have_key(:id)
    expect(item).to have_key(:type)
    expect(item).to have_key(:attributes)
    
    attributes = item[:attributes]
    expect(attributes).to have_key(:name)
    expect(attributes).to have_key(:description)
    expect(attributes).to have_key(:unit_price)
    expect(attributes).to have_key(:merchant_id)
  end
  
  describe "GET /api/v1/items" do
    before do
      @merchant = Merchant.create!(name: "Test Merchant")
      @item1 = Item.create!(name: "First Item", description: "Description 1", unit_price: 12.73, merchant: @merchant)
      @item2 = Item.create!(name: "Second Item", description: "Description 2", unit_price: 19.45, merchant: @merchant)
      @item3 = Item.create!(name: "Third Item", description: "Description 3", unit_price: 7.98, merchant: @merchant)
    end
    
    describe "happy path" do
      it "retrieves a list of all items" do
        get "/api/v1/items"
        
        expect_successful_response
        
        items = parse_response
        expect(items).to have_key(:data)
        expect(items[:data]).to be_an(Array)
        expect(items[:data].count).to eq(3)
        
        items[:data].each do |item|
          validate_item_structure(item)
        end
      end
      
      it "sorts items by price ascending" do
        get "/api/v1/items?sort=price"
        
        expect_successful_response
        
        items = parse_response[:data]
        prices = items.map { |item| item[:attributes][:unit_price] }
        expect(prices).to eq(prices.sort)
      end
      
      it "sorts items by price descending" do
        get "/api/v1/items?sort=price_desc"
        
        expect_successful_response
        
        items = parse_response[:data]
        prices = items.map { |item| item[:attributes][:unit_price] }
        expect(prices).to eq(prices.sort.reverse)
      end
    end
    
    describe "sad path" do
      it "no items exist" do
        Item.destroy_all
        
        get "/api/v1/items"
        
        expect_successful_response
        items = parse_response
        expect(items[:data]).to be_an(Array)
        expect(items[:data]).to be_empty
      end
      
      it "invalid sort parameter" do
        get "/api/v1/items?sort=invalid_sort"
        
        expect_error_response(400)
      end
    end
  end
  
  
end