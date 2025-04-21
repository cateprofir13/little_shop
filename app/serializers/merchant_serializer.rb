class MerchantSerializer
  include JSONAPI::Serializer
  
  attributes :name

  attribute :item_count, if: proc { |_record, params|
  params && params[:include_item_count]
  } do |merchant|
    merchant.item_count
 end
end