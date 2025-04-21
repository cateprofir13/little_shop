module Api
  module V1
    class MerchantCustomersController < BaseController
      def index
        merchant = Merchant.find(params[:merchant_id])
        customer_ids = merchant.invoices.pluck(:customer_id).uniq
        customers = Customer.where(id: customer_ids)
        render json: CustomerSerializer.new(customers).serializable_hash
      end
    end
  end
end