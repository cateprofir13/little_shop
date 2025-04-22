require 'rails_helper'

RSpec.describe "Merchant Invoices", type: :request do
  describe "GET /api/v1/merchants/:merchant_id/invoices" do
    it "returns all invoices for a given merchant" do
      merchant = Merchant.create!(name: "Mila Jackson")
      customer = Customer.create!(first_name: "Cal", last_name: "Suiter")
      invoice1 = merchant.invoices.create!(status: "shipped", customer_id: customer.id)
      invoice2 = merchant.invoices.create!(status: "returned", customer_id: customer.id)

      get "/api/v1/merchants/#{merchant.id}/invoices"

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      expect(parsed).to have_key(:data)
      expect(parsed[:data].length).to eq(2)

      parsed[:data].each do |invoice|
        expect(invoice).to have_key(:id)
        expect(invoice).to have_key(:type)
        expect(invoice[:type]).to eq("invoice")
        expect(invoice).to have_key(:attributes)
        expect(invoice[:attributes]).to have_key(:status)
      end
    end

    it 'returns invoices filtered by status' do
      merchant = Merchant.create!(name: "Test Merchant")
      customer = Customer.create!(first_name: "Cal", last_name: "Suiter")
      
      invoice1 = Invoice.create!(status: "shipped", merchant: merchant, customer: customer)
      invoice2 = Invoice.create!(status: "returned", merchant: merchant, customer: customer)
    
      get "/api/v1/merchants/#{merchant.id}/invoices?status=shipped"
    
      expect(response).to be_successful
    
      parsed = JSON.parse(response.body, symbolize_names: true)
      expect(parsed[:data].length).to eq(1)
      expect(parsed[:data].first[:attributes][:status]).to eq("shipped")
    end

    it "returns a 404 if merchant is not found" do
      get "/api/v1/merchants/999999/invoices" 
    
      expect(response).to have_http_status(:not_found)
    
      parsed = JSON.parse(response.body, symbolize_names: true)
      expect(parsed).to have_key(:errors)
      expect(parsed[:errors].first).to match(/Couldn't find Merchant/)
    end
  end
end