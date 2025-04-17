module Api
  module V1
    class MerchantsController < BaseController
      def index
        merchants = Merchant.all
        render json: MerchantSerializer.new(merchants)
      end

      
      def show
        merchant = Merchant.find(params[:id])
        render json: MerchantSerializer.new(merchant)
      end

      def create
        merchant = Merchant.create(merchant_params)
        render json: MerchantSerializer.new(merchant), status: :created
      end

      def destroy
        merchant = Merchant.find(params[:id])
        merchant.destroy
        head :no_content
      end

      def update
        merchant = Merchant.update(params[:id], merchant_params)
        render json: MerchantSerializer.new(merchant)
      end

      private
      
      def merchant_params
        params.require(:merchant).permit(:name)
      end
    end
  end
end