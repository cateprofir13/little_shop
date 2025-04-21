require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many(:items) }
    it { should have_many(:invoices) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end
  
  describe "class methods" do
    before(:each) do
      @merchant1 = Merchant.create!(name: "Ring World Jewelers")
      @merchant2 = Merchant.create!(name: "Computer Store")
      @merchant3 = Merchant.create!(name: "Golden Rings")
      @merchant4 = Merchant.create!(name: "Silver Shop")
      @merchant5 = Merchant.create!(name: "Gold Shop")
    end
    
    describe ".search_by_name" do
      it "merchants that match name" do
        expect(Merchant.search_by_name("ring")).to contain_exactly(@merchant1, @merchant3)
      end
      
      it "cAsE sensitive" do
        expect(Merchant.search_by_name("RING")).to contain_exactly(@merchant1, @merchant3)
      end
      
      it "no matches" do
        expect(Merchant.search_by_name("nonexistent")).to be_empty
      end
    end
    
    describe ".search" do
      it "merchants name" do
        expect(Merchant.search({name: "ring"})).to contain_exactly(@merchant1, @merchant3)
      end
      
      it "no parameters" do
        expect(Merchant.search({})).to be_empty
      end
      
      it "all merchants alphabetically" do
        result = Merchant.search({all: true})

        expect(result).to match_array([@merchant1, @merchant2, @merchant3, @merchant4, @merchant5])
        expect(result.map(&:name)).to eq(["Computer Store", "Gold Shop", "Golden Rings", "Ring World Jewelers", "Silver Shop"])
      end
      
      it "cAsE sensitive" do
        expect(Merchant.search({name: "RING"})).to contain_exactly(@merchant1, @merchant3)
      end
    end
  end
end