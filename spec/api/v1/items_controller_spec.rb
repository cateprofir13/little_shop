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
  
  describe "GET /api/v1/items/:id" do
    before do
      @merchant = Merchant.create!(name: "Test Merchant")
      @item = Item.create!(name: "Specific Item", description: "Description", unit_price: 16.82, merchant: @merchant)
    end
    
    describe "happy path" do
      it "item by ID" do
        get "/api/v1/items/#{@item.id}"
        
        expect_successful_response
        
        response_item = parse_response
        expect(response_item).to have_key(:data)
        
        validate_item_structure(response_item[:data])
        expect(response_item[:data][:id].to_i).to eq(@item.id)
        expect(response_item[:data][:attributes][:name]).to eq(@item.name)
      end
    end
    
    describe "sad path" do
      it "404 error when no item exists" do
        get "/api/v1/items/218482148"
        
        expect_error_response(404)
      end
    end
  end
  
  describe "POST /api/v1/items" do
    before do
      @merchant = Merchant.create!(name: "Test Merchant")
      @item_params = {
        name: "New Item",
        description: "New Description",
        unit_price: 32.47,
        merchant_id: @merchant.id
      }
    end
    
    describe "happy path" do
      it "create a new item with attributes" do
        headers = { "CONTENT_TYPE" => "application/json" }
        post "/api/v1/items", headers: headers, params: JSON.generate(@item_params)
        
        expect_successful_response(201)
        
        created_item = parse_response[:data]
        validate_item_structure(created_item)
        
        expect(created_item[:attributes][:name]).to eq(@item_params[:name])
        expect(created_item[:attributes][:description]).to eq(@item_params[:description])
        expect(created_item[:attributes][:unit_price]).to eq(@item_params[:unit_price])
        
        expect(Item.last.name).to eq(@item_params[:name])
      end
    end
    
    describe "sad path" do
      it "attributes are missing" do
        invalid_params = {
          description: "Invalid Item",
          unit_price: 8.52,
          merchant_id: @merchant.id
        }
        
        headers = { "CONTENT_TYPE" => "application/json" }
        post "/api/v1/items", headers: headers, params: JSON.generate(invalid_params)
        
        expect_error_response(422)
      end
      
      it "price is invalid" do
        invalid_params = @item_params.merge(unit_price: -4.25)
        
        headers = { "CONTENT_TYPE" => "application/json" }
        post "/api/v1/items", headers: headers, params: JSON.generate(invalid_params)
        
        expect_error_response(422)
      end
      
      it "merchant doesn't exist" do
        invalid_params = @item_params.merge(merchant_id: 492123)
        
        headers = { "CONTENT_TYPE" => "application/json" }
        post "/api/v1/items", headers: headers, params: JSON.generate(invalid_params)
        
        expect_error_response(404)
      end
    end
  end
  
  describe "PUT/PATCH /api/v1/items/:id" do
    before do
      @merchant = Merchant.create!(name: "Test Merchant")
      @merchant2 = Merchant.create!(name: "Another Merchant")
      @item = Item.create!(name: "Original Item", description: "Original Description", unit_price: 14.37, merchant: @merchant)
      @update_params = {
        name: "Updated Item",
        description: "Updated Description",
        unit_price: 27.83,
        merchant_id: @merchant.id
      }
    end
    
    describe "happy path" do
      it "updates an item" do
        headers = { "CONTENT_TYPE" => "application/json" }
        patch "/api/v1/items/#{@item.id}", headers: headers, params: JSON.generate(@update_params)
        
        expect_successful_response
        
        updated_item = parse_response[:data]
        validate_item_structure(updated_item)
        
        expect(updated_item[:attributes][:name]).to eq(@update_params[:name])
        expect(updated_item[:attributes][:description]).to eq(@update_params[:description])
        expect(updated_item[:attributes][:unit_price]).to eq(@update_params[:unit_price])
        
        @item.reload
        expect(@item.name).to eq(@update_params[:name])
      end
      
      it "updates an item with a new merchant" do
        update_merchant_params = @update_params.merge(merchant_id: @merchant2.id)
        
        headers = { "CONTENT_TYPE" => "application/json" }
        put "/api/v1/items/#{@item.id}", headers: headers, params: JSON.generate(update_merchant_params)
        
        expect_successful_response
        
        updated_item = parse_response[:data]
        expect(updated_item[:attributes][:merchant_id]).to eq(@merchant2.id)
        
        @item.reload
        expect(@item.merchant_id).to eq(@merchant2.id)
      end
    end
    
    describe "sad path" do
      it "item doesn't exist" do
        headers = { "CONTENT_TYPE" => "application/json" }
        patch "/api/v1/items/21323213", headers: headers, params: JSON.generate(@update_params)
        
        expect_error_response(404)
      end
      
      it "merchant doesn't exist" do
        invalid_params = @update_params.merge(merchant_id: 5921223)
        
        headers = { "CONTENT_TYPE" => "application/json" }
        patch "/api/v1/items/#{@item.id}", headers: headers, params: JSON.generate(invalid_params)
        
        expect_error_response(404)
      end
      
      it "invalid attributes" do
        invalid_params = { unit_price: -9.75 }
        
        headers = { "CONTENT_TYPE" => "application/json" }
        patch "/api/v1/items/#{@item.id}", headers: headers, params: JSON.generate(invalid_params)
        
        expect_error_response(422)
      end
    end
  end
  
  describe "DELETE /api/v1/items/:id" do
    before do
      @merchant = Merchant.create!(name: "Test Merchant")
      @item = Item.create!(name: "Deletable Item", description: "To be deleted", unit_price: 6.29, merchant: @merchant)
    end
    
    describe "happy path" do
      it "deletes item" do
        expect(Item.count).to eq(1)
        
        delete "/api/v1/items/#{@item.id}"
        
        expect_successful_response(204)
        expect(response.body).to be_empty
        
        expect(Item.count).to eq(0)
        expect { Item.find(@item.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    describe "sad path" do
      it "item doesn't exist" do
        delete "/api/v1/items/951232"
        
        expect_error_response(404)
      end
    end
  end
end