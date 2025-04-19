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