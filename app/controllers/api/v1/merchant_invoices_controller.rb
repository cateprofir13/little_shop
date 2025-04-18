module Api
	module V1
		class MerchantInvoicesController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
			def index
					merchant = Merchant.find(params[:merchant_id])
					invoices = merchant.invoices
					render json: InvoiceSerializer.new(invoices).serializable_hash
			end

      private

      def record_not_found(error)
        render json: { errors: [error.message] }, status: :not_found
      end
		end
	end
end
