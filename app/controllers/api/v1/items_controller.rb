module Api
  module V1
    class ItemsController < ApplicationController
      def index
        
      end
      
      def show
        
      end
      
      def create
        
      end
      
      def update
        
      end
      
      def destroy
        
      end

      private
      
      def item_params
        params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
      end
    end
  end
end