module Api
  module V1
    class ItemsController < BaseController
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
          item.save!
        end
      end

      def update
        item = Item.find(params[:id])
        Merchant.find(params[:merchant_id]) if params[:merchant_id].present?
        
        if item.update(item_params)
          render json: ItemSerializer.new(item)
        else
          item.update!(item_params)
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