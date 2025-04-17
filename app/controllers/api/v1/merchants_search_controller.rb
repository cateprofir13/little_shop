module Api
  module V1
    class SearchController < ApplicationController
      def show
        
      end
      
      private
      
      def search_params
        params.permit(:name)
      end
      
      def find_merchant
        
      end
    end
  end
end