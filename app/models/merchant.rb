class Merchant < ApplicationRecord
has_many :items
has_many :invoices

  def self.sorted_by_created_at(order = "desc")
    %w[asc desc].include?(order.downcase) ? order(created_at: order.downcase) : all
  end
end