module Api
  module V1
    class SearchController < ApplicationController
      def index
        if search_params.empty?
          render json: { message: 'Query invalid!', errors: ['No valid search parameter']}, status: :bad_request
          return
        end
        items = find_items
        render json: ItemSerializer.new(items)
      end
      
      private
      
      def search_params
        params.permit(:name, :min_price, :max_price)
      end
      
      def find_items
        items = items.all
        if params[:name].present?
          items = items.where('lower(name) ILIKE ?', "%#{params[:name].downcase}%")
        end
        if params[:min_price].present?
          items = items.where('unit_price >= ?', params[:min_price])
        end
        if params[:max_price].present?
          items = items.where('unit_price <= ?', params[:max_price])
        end
        items.order(:name)
      end
    end
  end
end