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
  def self.with_item_counts
     left_joins(:items)
      .select("merchants.*, COUNT(DISTINCT items.id) AS item_count")
      .group("merchants.id")
  end

  def item_count
    self[:item_count] || items.count
  end
end