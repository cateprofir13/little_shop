require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many(:items) }
    it { should have_many(:invoices) }
  end
end