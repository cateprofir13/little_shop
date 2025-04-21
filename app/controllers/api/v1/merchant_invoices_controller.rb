module Api
  module V1
    class MerchantInvoicesController < BaseController
      def index
        merchant = Merchant.find(params[:merchant_id])
        
        if params[:status].present?
          invoices = merchant.invoices.where(status: params[:status])
        else
          invoices = merchant.invoices
        end
        
        render json: InvoiceSerializer.new(invoices)
      end
    end
  end
end