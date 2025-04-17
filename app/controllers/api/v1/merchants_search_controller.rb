module Api
  module V1
    class SearchController < ApplicationController
      def show
        if search_params.empty?
          render json: { message: 'Query invalid!', errors: ['No valid search parameter']}, status: :bad_request
          return
        end
        merchant = find_merchant
        if merchant.nil?
          render json: { data: {} }
        else
          render json: MerchantSerializer.new(merchant)
        end
      end
      
      private
      
      def search_params
        params.permit(:name)
      end
      
      def find_merchant
        if params[:name].present?
          Merchant.where?('lower(name) ILIKE ?', "%#{params[:name].downcase}%").first
        end
      end
    end
  end
end