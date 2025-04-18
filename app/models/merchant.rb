class Merchant < ApplicationRecord
has_many :items
has_many :invoices
validates_presence_of :name


  def self.search_by_name(name)
    where('lower(name) ILIKE ?', "%#{name.downcase}%")
  end

  def self.search(params)
    if params[:name].present?
      search_by_name(params[:name])
    elsif params[:all]
      all.order(:name)
    else
      none
    end
  end
end