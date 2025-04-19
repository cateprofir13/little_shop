require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many(:items) }
    it { should have_many(:invoices) }
  end

  it "displays merchants in order of newest to oldest" do
    merchant1 = Merchant.create(name:"Alvin", created_at:3.days.ago)
    merchant2 = Merchant.create(name:"Simon", created_at:2.days.ago)
    merchant3 = Merchant.create(name:"Theodore", created_at:1.day.ago)

    result = Merchant.sorted_by_created_at
    expect(result).to eq([merchant3, merchant2, merchant1])
  end

  
  it "returns only merchants with returned items" do
  
    merchant_with_return = Merchant.create!(name: "Returned Merchant")
    merchant_no_return = Merchant.create!(name: "Regular Merchant")

    item1 = merchant_with_return.items.create!(name: "Item 1", description: "desc", unit_price: 10)
    item2 = merchant_no_return.items.create!(name: "Item 2", description: "desc", unit_price: 15)

    customer = Customer.create!(first_name: "Cal", last_name: "Suiter")

    returned_invoice = Invoice.create!(
      status: "returned",
      customer: customer,
      merchant: merchant_with_return
    )
    
    shipped_invoice = Invoice.create!(
      status: "shipped",
      customer: customer,
      merchant: merchant_no_return
    )

    InvoiceItem.create!(invoice: returned_invoice, item: item1, quantity: 1, unit_price: 10)
    InvoiceItem.create!(invoice: shipped_invoice, item: item2, quantity: 1, unit_price: 15)

    result = Merchant.with_returned_items

    expect(result).to include(merchant_with_return)
    expect(result).not_to include(merchant_no_return)
  end
end
