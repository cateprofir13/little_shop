module Api
	module V1
		class MerchantCustomersController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
			def index
						merchant = Merchant.find(params[:merchant_id])
						customer_ids = merchant.invoices.pluck(:customer_id).uniq
						customers = Customer.where(id: customer_ids)
						render json: CustomerSerializer.new(customers).serializable_hash
			end
      
      private

      def record_not_found(error)
        render json: { errors: [error.message] }, status: :not_found
      end
		end
	end
end
