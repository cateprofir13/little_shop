module Api
  module V1
    module Merchants
      class SearchController < BaseController
        def show
          if params[:name].blank?
            render json: { 
              message: "your query could not be completed", 
              errors: ["No valid search parameter"] 
            }, status: :bad_request
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
            Merchant.where('lower(name) ILIKE ?', "%#{params[:name].downcase}%").first
          end
        end
      end
    end
  end
end