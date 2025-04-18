require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe Item, type: :model do
  describe "relationships" do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_numericality_of(:unit_price).is_greater_than(0) }
  end
  
  describe "class methods" do
    before(:each) do
      @merchant1 = Merchant.create!(name: "Merchant 1")
      @merchant2 = Merchant.create!(name: "Merchant 2")
      
      @item1 = Item.create!(name: "Diamond Ring", description: "A ring with a diamond", unit_price: 5.99, merchant: @merchant1)
      @item2 = Item.create!(name: "Computer", description: "A computational device", unit_price: 100.00, merchant: @merchant1)
      @item3 = Item.create!(name: "Gold Ring", description: "A ring made of gold", unit_price: 250.00, merchant: @merchant2)
      @item4 = Item.create!(name: "Silver Bracelet", description: "A bracelet made of silver", unit_price: 80.00, merchant: @merchant2)
      @item5 = Item.create!(name: "Bronze Medal", description: "Third place prize", unit_price: 10.00, merchant: @merchant1)
    end
    
    describe ".search_by_name" do
      it "items that match the name" do
        results = Item.search_by_name("ring")
        expect(results).to contain_exactly(@item1, @item3)
        expect(results).not_to include(@item2)
      end
      
      it "cAsE insensitive" do
        expect(Item.search_by_name("RING")).to contain_exactly(@item1, @item3)
      end
      
      it "no matches" do
        expect(Item.search_by_name("nonexistent")).to be_empty
      end
    end
    
    describe ".search_by_price_range" do
      it "items witin price range" do
        expect(Item.search_by_price_range(50, 150)).to contain_exactly(@item2, @item4)
      end
      
      it "item boundries" do
        expect(Item.search_by_price_range(10, 250)).to contain_exactly(@item2, @item3, @item4, @item5)
      end
      
      it "order results by name" do
        results = Item.search_by_price_range(10, 250)
        expect(results.to_a).to eq(results.sort_by(&:name))
      end
    end
    
    describe ".search_by_min_price" do
      it "items above minimum price" do
        expect(Item.search_by_min_price(90)).to contain_exactly(@item2, @item3)
      end
      
      it "items boundaries" do
        expect(Item.search_by_min_price(10)).to contain_exactly(@item2, @item3, @item4, @item5)
      end
      
      it "order results by name" do
        results = Item.search_by_min_price(10)
        expect(results.to_a).to eq(results.sort_by(&:name))
      end
    end
    
    describe ".search_by_max_price" do
      it "items below maximum price" do
        expect(Item.search_by_max_price(90)).to contain_exactly(@item1, @item4, @item5)
      end
      
      it "items boundaries" do
        expect(Item.search_by_max_price(100)).to contain_exactly(@item1, @item2, @item4, @item5)
      end
      
      it "order results by name" do
        results = Item.search_by_max_price(100)
        expect(results.to_a).to eq(results.sort_by(&:name))
      end
    end
    
    describe ".search" do
      it "searches by name" do
        expect(Item.search({name: "ring"})).to contain_exactly(@item1, @item3)
      end
      
      it "searches by price range" do
        expect(Item.search({min_price: 50, max_price: 150})).to contain_exactly(@item2, @item4)
      end
      
      it "searches by min_price" do
        expect(Item.search({min_price: 90})).to contain_exactly(@item2, @item3)
      end
      
      it "searches by max_price" do
        expect(Item.search({max_price: 90})).to contain_exactly(@item1, @item4, @item5)
      end
      
      it "no parameters" do
        expect(Item.search({})).to be_empty
      end
      
      it "order results by name" do
        results = Item.search({name: "r"})
        expect(results.to_a).to eq(results.sort_by(&:name))
      end
    end
  end
end