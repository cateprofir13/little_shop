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

#  it "can create a new poster" do


#   end

end