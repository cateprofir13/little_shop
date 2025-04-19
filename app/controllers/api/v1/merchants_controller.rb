module Api
  module V1
    class MerchantsController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def index
        merchants = Merchant.all
        
        if params[:sorted] == "age"
          merchants = merchants.sorted_by_created_at
        end

        if params[:count] == "true"
          merchants = merchants.with_item_counts
        end

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

      def with_item_counts
        merchant = Merchant.with_item_counts
        render json: MerchantSerializer.new(merchant)
      end

      private
      def merchant_params
        params.require(:merchant).permit(:name)
      end

      def record_not_found(error)
        render json: { errors: [error.message] }, status: :not_found
      end

    end
  end
end