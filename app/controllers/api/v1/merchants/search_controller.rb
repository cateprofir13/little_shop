module Api
  module V1
    module Merchants
      class SearchController < BaseController
        before_action :validate_search_parameters
        
        def show
          merchant = find_merchant
          
          if merchant.nil?
            render json: { data: {} }
          else
            render json: MerchantSerializer.new(merchant)
          end
        end

        def index
          merchants = find_all_merchants
          
          render json: MerchantSerializer.new(merchants)
        end
        
        private
        
        def validate_search_parameters
          if all_params_blank?([:name])
            render_error("No valid search parameter")
            return
          end
        end
        
        def search_params
          params.permit(:name)
        end
        
        def find_merchant
          if params[:name].present?
            Merchant.where('lower(name) ILIKE ?', "%#{params[:name].downcase}%").first
          end
        end
        
        def find_all_merchants
          if params[:name].present?
            Merchant.where('lower(name) ILIKE ?', "%#{params[:name].downcase}%")
          else
            []
          end
        end
      end
    end
  end
end