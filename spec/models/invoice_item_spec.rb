require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe InvoiceItem, type: :model do
  describe "relationships" do
    it { should belong_to(:invoice) }
    it { should belong_to(:item) }
  end
end