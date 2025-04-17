module Api
  module V1
    class SearchController < ApplicationController
      def index
        
      end
      
      private
      
      def search_params
        params.permit(:name, :min_price, :max_price)
      end
      
      def find_items
        
      end
    end
  end
end