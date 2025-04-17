module Api
  module V1
    class ItemsController < ApplicationController
      def index
        items = if params[:sorted] == "price" || params[:sort] == "price" || params[:sort] == "price_asc"
                  Item.order(unit_price: :asc)
                elsif params[:sort] == "price_desc"
                  Item.order(unit_price: :desc)
                else
                  Item.all
                end
                
        render json: ItemSerializer.new(items)
      end
      
      def show
        item = Item.find(params[:id])
        render json: ItemSerializer.new(item)
      end
      
      def create
        item = Item.new(item_params)
        if item.save
          render json: ItemSerializer.new(item), status: :created
        else
          render json: { 
            message: "your query could not be completed",
            errors: item.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        item = Item.find(params[:id])
        
        # Check if merchant_id exists
        if params[:merchant_id].present?
          begin
            Merchant.find(params[:merchant_id])
          rescue ActiveRecord::RecordNotFound
            render json: { 
              message: "your query could not be completed",
              errors: ["Merchant must exist"]
            }, status: :not_found
            return
          end
        end
        
        if item.update(item_params)
          render json: ItemSerializer.new(item)
        else
          render json: { 
            message: "your query could not be completed",
            errors: item.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      def destroy
        item = Item.find(params[:id])
        item.destroy
        head :no_content
      end

      private
      
      def item_params
        params.permit(:name, :description, :unit_price, :merchant_id)
      end
    end
  end
end