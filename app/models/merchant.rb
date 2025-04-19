class Merchant < ApplicationRecord
has_many :items
has_many :invoices

  def self.sorted_by_created_at(order = "desc")
    %w[asc desc].include?(order.downcase) ? order(created_at: order.downcase) : all
  end


  def self.with_returned_items
    joins(items: { invoice_items: :invoice })
      .where(invoices: { status: 'returned' })
      .distinct
  end
end