require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe "Items Search API", type: :request do
  let(:create_test_data) do
    @merchant1 = Merchant.create!(name: "Merchant 1", id: 1)
    @merchant2 = Merchant.create!(name: "Merchant 2", id: 2)
    
    @item1 = Item.create!(
      id: 4,
      name: "Item Nemo Facere",
      description: "Sunt eum id eius magni consequuntur delectus veritatis.",
      unit_price: 42.91,
      merchant_id: @merchant1.id
    )
    
    @item2 = Item.create!(
      id: 5,
      name: "Item Expedita Aliquam",
      description: "Voluptate aut labore qui illum tempore eius.",
      unit_price: 687.23,
      merchant_id: @merchant1.id
    )
    
    @item3 = Item.create!(
      id: 6,
      name: "Item Provident At",
      description: "Numquam officiis reprehenderit eum ratione neque tenetur.",
      unit_price: 159.25,
      merchant_id: @merchant1.id
    )
    
    @item4 = Item.create!(
      id: 18,
      name: "Item Reiciendis Est",
      description: "Velit deleniti facilis quo autem.",
      unit_price: 36.46,
      merchant_id: @merchant2.id
    )
    
    @item5 = Item.create!(
      id: 7,
      name: "Item Expedita Fuga",
      description: "Fuga assumenda occaecati hic dolorem tenetur dolores nisi.",
      unit_price: 311.63,
      merchant_id: @merchant1.id
    )
    
    @item6 = Item.create!(
      id: 10,
      name: "Item Quidem Suscipit",
      description: "Reiciendis sed aperiam culpa animi laudantium.",
      unit_price: 340.18,
      merchant_id: @merchant1.id
    )
  end
  
  def expect_successful_response
    expect(response).to be_successful
    expect(response.status).to eq(200)
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
  
  def validate_structure(item)
    expect(item).to have_key(:id)
    expect(item).to have_key(:type)
    expect(item).to have_key(:attributes)
    expect(item[:attributes]).to have_key(:name)
    expect(item[:attributes]).to have_key(:description)
    expect(item[:attributes]).to have_key(:unit_price)
    expect(item[:attributes]).to have_key(:merchant_id)
  end

  describe "GET /api/v1/items/find" do
    before { create_test_data }

    describe "happy path" do
      it "finds an item by name fragment" do
        get "/api/v1/items/find?name=exped"
        
        expect_successful_response
        
        parsed_response = parse_response
        expect(parsed_response).to have_key(:data)
        expect(parsed_response[:data]).to be_a(Hash)
        
        item = parsed_response[:data]
        validate_structure(item)
        
        expect(item[:attributes][:name]).to eq("Item Expedita Aliquam")
      end

      it "finds an item by min_price" do
        get "/api/v1/items/find?min_price=300"
        
        expect_successful_response
        item = parse_response[:data]
        expect(item[:attributes][:unit_price]).to be >= 300
        
        matching_items = [@item2, @item5, @item6]
        first_alphabetical = matching_items.sort_by { |i| i.name }.first
        expect(item[:attributes][:name]).to eq(first_alphabetical.name)
      end

      it "finds an item by max_price" do
        get "/api/v1/items/find?max_price=100"
        
        expect_successful_response
        item = parse_response[:data]
        expect(item[:attributes][:unit_price]).to be <= 100
        
        matching_items = [@item1, @item4]
        first_alphabetical = matching_items.sort_by { |i| i.name }.first
        expect(item[:attributes][:name]).to eq(first_alphabetical.name)
      end

      it "finds an item by price range" do
        get "/api/v1/items/find?min_price=40&max_price=200"
        
        expect_successful_response
        item = parse_response[:data]
        expect(item[:attributes][:unit_price]).to be_between(40, 200)
        
        matching_items = [@item1, @item3]
        first_alphabetical = matching_items.sort_by { |i| i.name }.first
        expect(item[:attributes][:name]).to eq(first_alphabetical.name)
      end

      it "no items match name" do
        get "/api/v1/items/find?name=NOMATCH"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response).to have_key(:data)
        expect(parsed_response[:data]).to eq({})
      end
      
      it "no items match price" do
        get "/api/v1/items/find?min_price=9999"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response).to have_key(:data)
        expect(parsed_response[:data]).to eq({})
      end
    end

    describe "sad path" do
      it "no parameters are provided" do
        get "/api/v1/items/find"
        expect_error_response
      end

      it "min_price is negative" do
        get "/api/v1/items/find?min_price=-10"
        expect_error_response
      end

      it "max_price is negative" do
        get "/api/v1/items/find?max_price=-10"
        expect_error_response
      end

      it "min_price > max_price" do
        get "/api/v1/items/find?min_price=100&max_price=50"
        expect_error_response
      end

      it "name and price parameters are mixed up" do
        get "/api/v1/items/find?name=item&min_price=50"
        expect_error_response
      end
      
      it "empty paramaters are provided" do
        get "/api/v1/items/find?name="
        expect_error_response
      end

      it "parameter is unexpected" do
        get "/api/v1/items/find?unexpected_param=value"
        
        expect_error_response
      end
      
      it "decimal min_price=0" do
        get "/api/v1/items/find?min_price=0"
        expect_error_response
      end
    end
  end

  describe "GET /api/v1/items/find_all" do
    before { create_test_data }

    describe "happy path" do
      it "items matching half a name" do
        get "/api/v1/items/find_all?name=exped"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response).to have_key(:data)
        expect(parsed_response[:data]).to be_an(Array)
        expect(parsed_response[:data].length).to eq(2)
        
        names = parsed_response[:data].map { |item| item[:attributes][:name] }
        expect(names).to include("Item Expedita Aliquam", "Item Expedita Fuga")
        
        parsed_response[:data].each { |item| validate_structure(item) }
      end

      it "items matching half a name cAsE specific" do
        get "/api/v1/items/find_all?name=EXPED"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response[:data].length).to eq(2)
        
        names = parsed_response[:data].map { |item| item[:attributes][:name] }
        expect(names).to include("Item Expedita Aliquam", "Item Expedita Fuga")
      end

      it "items above a min price" do
        get "/api/v1/items/find_all?min_price=300"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response[:data].length).to eq(3)
        
        prices = parsed_response[:data].map { |item| item[:attributes][:unit_price] }
        expect(prices.all? { |price| price >= 300 }).to be true
        
        ids = parsed_response[:data].map { |item| item[:id].to_i }
        expect(ids).to include(5, 7, 10)
      end

      it "items below a max price" do
        get "/api/v1/items/find_all?max_price=100"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response[:data].length).to eq(2)
        
        prices = parsed_response[:data].map { |item| item[:attributes][:unit_price] }
        expect(prices.all? { |price| price <= 100 }).to be true
        
        ids = parsed_response[:data].map { |item| item[:id].to_i }
        expect(ids).to include(4, 18)
      end

      it "items in a price range" do
        get "/api/v1/items/find_all?min_price=40&max_price=350"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response[:data].length).to eq(4)
        
        prices = parsed_response[:data].map { |item| item[:attributes][:unit_price] }
        expect(prices.all? { |price| price >= 40 && price <= 350 }).to be true
        
        ids = parsed_response[:data].map { |item| item[:id].to_i }
        expect(ids).to include(4, 6, 7, 10)
      end

      it "no items match name" do
        get "/api/v1/items/find_all?name=xxxkungfufighterxxx"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response[:data]).to be_an(Array)
        expect(parsed_response[:data]).to be_empty
      end
      
      it "no items match price" do
        get "/api/v1/items/find_all?min_price=24922194"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response[:data]).to be_an(Array)
        expect(parsed_response[:data]).to be_empty
      end
    end

    describe "sad path" do
      it "no parameters are provided" do
        get "/api/v1/items/find_all"
        expect_error_response
      end

      it "min_price is negative" do
        get "/api/v1/items/find_all?min_price=-10"
        expect_error_response
      end
      
      it "max_price is negative" do
        get "/api/v1/items/find_all?max_price=-10"
        expect_error_response
      end
      
      it "min_price > max_price" do
        get "/api/v1/items/find_all?min_price=100&max_price=50"
        expect_error_response
      end
      
      it "name and price parameters are mixed" do
        get "/api/v1/items/find_all?name=item&min_price=50"
        expect_error_response
      end

      it "parameter is unexptected" do
        get "/api/v1/items/find_all?unexpected_param=value"
        
        expect_error_response
      end
      
      it "empty parameters are provided" do
        get "/api/v1/items/find_all?name="
        expect_error_response
      end
    end
  end
end