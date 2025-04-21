module Api
	module V1
		class MerchantItemsController < BaseController
      def index
        merchant = Merchant.find(params[:merchant_id])
        items = merchant.items
        render json: ItemSerializer.new(items).serializable_hash
      end
		end
	end
end
