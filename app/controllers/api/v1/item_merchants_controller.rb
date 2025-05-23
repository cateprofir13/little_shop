module Api
  module V1
    class ItemMerchantsController < BaseController
      def show
        item = Item.find(params[:item_id])
        render json: MerchantSerializer.new(item.merchant)
      end
    end
  end
end