require 'rails_helper'

RSpec.describe "Merchant Customers API", type: :request do
  describe "GET /api/v1/merchants/:merchant_id/customers" do
    it "returns all unique customers who have invoices with the merchant" do
      merchant = Merchant.create!(name: "Test Merchant")
      customer1 = Customer.create!(first_name: "Alice", last_name: "Anderson")
      customer2 = Customer.create!(first_name: "Bob", last_name: "Brown")
      customer3 = Customer.create!(first_name: "Charlie", last_name: "Clark")

      # Only customer1 and customer2 have invoices with the merchant
      Invoice.create!(merchant: merchant, customer: customer1, status: "shipped")
      Invoice.create!(merchant: merchant, customer: customer1, status: "returned")
      Invoice.create!(merchant: merchant, customer: customer2, status: "pending")
      # This invoice is for a different merchant
      other_merchant = Merchant.create!(name: "Other Merchant")
      Invoice.create!(merchant: other_merchant, customer: customer3, status: "shipped")

      get "/api/v1/merchants/#{merchant.id}/customers"

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      expect(parsed).to have_key(:data)
      expect(parsed[:data].size).to eq(2)

      customer_names = parsed[:data].map { |c| c[:attributes][:first_name] }
      expect(customer_names).to include("Alice", "Bob")
      expect(customer_names).not_to include("Charlie")
    end
  end

  it "returns 404 and an error message when merchant is not found" do
    get "/api/v1/merchants/999999/customers"

    expect(response).to have_http_status(:not_found)

    parsed = JSON.parse(response.body, symbolize_names: true)
    expect(parsed).to have_key(:errors)
    expect(parsed[:errors].first).to match(/Couldn't find Merchant/)
  end
end
