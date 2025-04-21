module Api
	module V1
		class MerchantItemsController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
			def index
						merchant = Merchant.find(params[:merchant_id])
						items = merchant.items
						render json: ItemSerializer.new(items).serializable_hash
			end

      private

      def record_not_found(error)
        render json: { errors: [error.message] }, status: :not_found
      end

		end
	end
end
