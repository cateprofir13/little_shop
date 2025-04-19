class MerchantSerializer
  include JSONAPI::Serializer
  
  attributes :name

  attribute :item_count do |merchant|
   merchant.item_count
  end
end