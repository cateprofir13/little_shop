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
end