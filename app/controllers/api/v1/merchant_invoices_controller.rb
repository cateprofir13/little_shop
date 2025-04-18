module Api
	module V1
		class MerchantInvoicesController < ApplicationController
			def index
					merchant = Merchant.find(params[:merchant_id])
					invoices = merchant.invoices
					render json: InvoiceSerializer.new(invoices).serializable_hash
			end
		end
	end
end
