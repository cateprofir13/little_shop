require 'rails_helper'

describe "Merchants API", type: :request do
  it "sends a list of merchants" do
    Merchant.create(name: "Schroeder-Jerde")
    Merchant.create(name: "Glover Inc")
    Merchant.create(name: "Kutch, Blick and O'Keefe")

    get "/api/v1/merchants"

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)
    expect(merchants).to have_key(:data)
    expect(merchants[:data]).to be_an(Array)
    expect(merchants[:data].length).to eq(3)
    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it "sends one poster" do 
    merchant = Merchant.create(name: "Schroeder-Jerde")

    get "/api/v1/merchants/#{merchant.id}"

    expect(response).to be_successful

    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(merchant).to have_key(:data)

    data = merchant[:data]
    expect(data).to have_key(:attributes)
    expect(data[:attributes]).to have_key(:name)
    expect(data[:attributes][:name]).to be_a(String)
    expect(data[:attributes][:name]).to eq("Schroeder-Jerde")
  end

  it 'can create a new merchant' do
    merchant_params = {
                        name: "Calvin D Suiter",
    }
    headers = { "CONTENT_TYPE" => "application/json"}

    post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: merchant_params)
    created_merchant = Merchant.last         

    expect(response).to be_successful
    expect(created_merchant.name).to eq(merchant_params[:name])
  end

  it 'can delete a merchant and all its items' do
    merchant = Merchant.create!(name: "Calvin D Suiter")
    item1 = merchant.items.create!(name: "Thing 1", description: "desc", unit_price: 10.0)
    item2 = merchant.items.create!(name: "Thing 2", description: "desc", unit_price: 15.0)
  
    expect(Merchant.count).to eq(1)
    expect(Item.count).to eq(2)
  
    delete "/api/v1/merchants/#{merchant.id}"
  
    expect(response).to have_http_status(:no_content)
    expect(Merchant.count).to eq(0)
    expect(Item.count).to eq(0) #cascadng
  
    expect { Merchant.find(merchant.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'can update a merchant' do
    merchantId = Merchant.create(name: "Kutch, Blick and O'Keefe").id

    previous_name = Merchant.last.name
    merchant_params = {name: "Profir Suiter"}
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/merchants/#{merchantId}", headers: headers, params: JSON.generate({merchant: merchant_params})

    merchant = Merchant.find_by(id: merchantId)
    expect(response).to be_successful
    expect(merchant.name).to_not eq(previous_name)
    expect(merchant.name).to eq("Profir Suiter")
  end

  it "returns a 404 and error message if merchant is not found" do
    
    get "/api/v1/merchants/999999"
  
    expect(response).to have_http_status(:not_found)
  
    error_response = JSON.parse(response.body, symbolize_names: true)
    expect(error_response).to have_key(:errors)
    expect(error_response[:errors].first).to match(/Couldn't find Merchant/)
  end


end