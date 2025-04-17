module Api
  module V1
    class ItemsController < ApplicationController
      def index
        render json: ItemSerializer.new(Item.all)
      end
      
      def show
        render json: ItemSerializer.new(Item.find(params[:id]))
      end
      
      def create
        render json: ItemSerializer.new(Item.create!(item_params[:item])), status: :created
      end
      
      def update
        render json: ItemSerializer.new(Item.update!(item_params[:item])), status: :ok
      end
      
      def destroy
        item = Item.find(params[:id])
        item.destroy
        head :no_content
      end

      private
      
      def item_params
        params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
      end
    end
  end
end