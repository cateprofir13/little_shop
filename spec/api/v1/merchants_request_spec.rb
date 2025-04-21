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

  it 'can create a new merchant with only name' do
    headers = { "CONTENT_TYPE" => "application/json" }
  
    post "/api/v1/merchants", headers: headers, params: JSON.generate({ merchant: { name: "Toys R Us" } })
  
    expect(response).to have_http_status(:created)
  
    parsed = JSON.parse(response.body, symbolize_names: true)
    expect(parsed[:data][:attributes][:name]).to eq("Toys R Us")
  end

  it 'returns an error if name param is missing entirely' do
    headers = { "CONTENT_TYPE" => "application/json" }
  
    post "/api/v1/merchants", headers: headers, params: JSON.generate({})
  
    expect(response).to have_http_status(:bad_request)
  
    parsed = JSON.parse(response.body, symbolize_names: true)
    expect(parsed[:errors].first).to match(/Missing required parameters: merchant/i)
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

  it "returns serialized merchants with item_count when count=true is passed" do
    merchant = Merchant.create!(name: "Test Merchant")
    merchant.items.create!(name: "Item A", description: "desc", unit_price: 10)
    merchant.items.create!(name: "Item B", description: "desc", unit_price: 15)
  
    get "/api/v1/merchants?count=true"
  
    expect(response).to be_successful
  
    parsed = JSON.parse(response.body, symbolize_names: true)
    merchant_data = parsed[:data].first
  
    expect(merchant_data[:attributes]).to include(:item_count)
    expect(merchant_data[:attributes][:item_count]).to eq(2)
  end


  it "returns merchants sorted from newest to oldest via index controller" do
    m1 = Merchant.create!(name: "Old", created_at: 3.days.ago)
    m2 = Merchant.create!(name: "Mid", created_at: 2.days.ago)
    m3 = Merchant.create!(name: "New", created_at: 1.day.ago)
  
    get "/api/v1/merchants?sorted=age"
  
    expect(response).to be_successful
    parsed = JSON.parse(response.body, symbolize_names: true)
    names = parsed[:data].map { |m| m[:attributes][:name] }
    expect(names).to eq(["New", "Mid", "Old"])
  end

  it "returns only merchants with returned items" do
    merchant = Merchant.create!(name: "Returned Merchant")
    item = merchant.items.create!(name: "Item A", description: "desc", unit_price: 10)
    customer = Customer.create!(first_name: "Jane", last_name: "Doe")
    invoice = Invoice.create!(status: "returned", merchant: merchant, customer: customer)
    InvoiceItem.create!(item: item, invoice: invoice, quantity: 1, unit_price: 10)

    get "/api/v1/merchants?returned_items=true"

    expect(response).to be_successful
    parsed = JSON.parse(response.body, symbolize_names: true)
    expect(parsed[:data].length).to eq(1)
    expect(parsed[:data].first[:attributes][:name]).to eq("Returned Merchant")
  end

  it "returns merchants with item counts" do
    merchant1 = Merchant.create(name:"Alvin")
    merchant2 = Merchant.create(name:"Simon")

    Item.create!(name: "Axe", description: "Tool", unit_price: 10, merchant: merchant2)
    Item.create!(name: "Chainsaw", description: "Tool", unit_price: 30, merchant: merchant1)
    Item.create!(name: "Wedge", description: "Tool", unit_price: 20, merchant: merchant2)

    result = Merchant.with_item_counts

    merchant_with_counts = result.map {|merchant| [merchant.name, merchant.item_count.to_i] }.to_h

    expect(merchant_with_counts).to eq({"Alvin" => 1, "Simon" => 2})
  end

end