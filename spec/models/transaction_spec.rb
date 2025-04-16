require 'rails_helper'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe Transaction, type: :model do
  describe "relationships" do
    it { should belong_to(:invoice) }
  end
end