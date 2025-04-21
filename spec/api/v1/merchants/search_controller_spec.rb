require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe "Merchants Search API", type: :request do
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
  
  def validate_merchant_structure(merchant)
    expect(merchant).to have_key(:id)
    expect(merchant).to have_key(:type)
    expect(merchant).to have_key(:attributes)
    expect(merchant[:attributes]).to have_key(:name)
  end

  let(:create_test_data) do
    @merchant4 = Merchant.create!(name: "he test 4")
    @merchant1 = Merchant.create!(name: "math test 1")
    @merchant5 = Merchant.create!(name: "google test 5")
    @merchant3 = Merchant.create!(name: "da test 3")
    @merchant2 = Merchant.create!(name: "Turing")
  end

  describe "GET /api/v1/merchants/find" do
    before { create_test_data }

    describe "happy path" do
      it "finds a merchant by half name" do
        get "/api/v1/merchants/find?name=test"
        
        expect_successful_response
        
        parsed_response = parse_response
        expect(parsed_response).to have_key(:data)
        expect(parsed_response[:data]).to be_a(Hash)
        
        merchant = parsed_response[:data]
        validate_merchant_structure(merchant)
        
        expect(merchant[:attributes][:name]).to eq("he test 4")
      end

      it "no merchants match" do
        get "/api/v1/merchants/find?name=NOMATCH"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response).to have_key(:data)
        expect(parsed_response[:data]).to eq({})
      end
      
      it "cAsE insensitive" do
        get "/api/v1/merchants/find?name=TEST"
        
        expect_successful_response
        merchant = parse_response[:data]
        expect(merchant[:attributes][:name]).to eq("he test 4")
      end
    end

    describe "sad path" do
      it "no search parameter" do
        get "/api/v1/merchants/find"
        expect_error_response
      end
      
      it "search parameter" do
        get "/api/v1/merchants/find?name="
        expect_error_response
      end
    end
  end

  describe "GET /api/v1/merchants/find_all" do
    before { create_test_data }

    describe "happy path" do
      it "finds all merchants by half name" do
        get "/api/v1/merchants/find_all?name=test"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response).to have_key(:data)
        expect(parsed_response[:data]).to be_an(Array)
        expect(parsed_response[:data].length).to eq(4)
        
        names = parsed_response[:data].map { |merchant| merchant[:attributes][:name] }
        expect(names).to include("math test 1", "da test 3", "he test 4", "google test 5")
       
        expected_order = ["he test 4", "math test 1", "google test 5", "da test 3"]
        expect(names).to eq(expected_order)
        
        parsed_response[:data].each { |merchant| validate_merchant_structure(merchant) }
      end

      it "cAsE insensitive" do
        get "/api/v1/merchants/find_all?name=TEST"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response[:data].length).to eq(4)
        
        names = parsed_response[:data].map { |merchant| merchant[:attributes][:name] }
        expect(names).to include("math test 1", "da test 3", "he test 4", "google test 5")
      end

      it "no merchants match" do
        get "/api/v1/merchants/find_all?name=NOMATCHHERE"
        
        expect_successful_response
        parsed_response = parse_response
        expect(parsed_response[:data]).to be_an(Array)
        expect(parsed_response[:data]).to be_empty
      end
    end

    describe "sad path" do
      it "no search parameter" do
        get "/api/v1/merchants/find_all"
        expect_error_response
      end
      
      it "search parameter is empty" do
        get "/api/v1/merchants/find_all?name="
        expect_error_response
      end
    end
  end
end