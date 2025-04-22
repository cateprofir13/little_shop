class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: { greater_than: 0 }

  def self.search_by_name(name)
    where('lower(name) ILIKE ?', "%#{name.downcase}%")
  end
  
  def self.search_by_price_range(min_price, max_price)
    where('unit_price >= ? AND unit_price <= ?', min_price, max_price)
      .order(:name)
  end
  
  def self.search_by_min_price(min_price)
    where('unit_price >= ?', min_price).order(:name)
  end
  
  def self.search_by_max_price(max_price)
    where('unit_price <= ?', max_price).order(:name)
  end
  
  def self.search(params)
    if params[:name].present?
      where('lower(name) ILIKE ?', "%#{params[:name].downcase}%")
        .order(:name)
    elsif params[:min_price].present? && params[:max_price].present?
      where('unit_price >= ? AND unit_price <= ?', params[:min_price], params[:max_price])
        .order(:name)
    elsif params[:min_price].present?
      where('unit_price >= ?', params[:min_price])
        .order(:name)
    elsif params[:max_price].present?
      where('unit_price <= ?', params[:max_price])
        .order(:name)
    else
      none
    end
  end
end