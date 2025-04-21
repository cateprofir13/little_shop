module Api
  module V1
    module Items
      class SearchController < BaseController
        before_action :validate_search_parameters
        
        def show
          item = find_item
          if item.nil?
            render json: { data: {} }
          else
            render json: ItemSerializer.new(item)
          end
        end

        def index
          items = find_items
          render json: ItemSerializer.new(items)
        end
        
        private
        
        def validate_search_parameters
          if all_params_blank?([:name, :min_price, :max_price])
            render_error("No valid search parameter")
            return
          end
          
          if negative_price_params?
            render_error("Price parameters cannot be negative")
            return
          end
          
          if invalid_parameter_combinations?
            render_error("Cannot mix name and price parameters")
            return
          end
          
          if invalid_price_range?
            render_error("Min price must be less than max price")
            return
          end
        end
        
        def invalid_price_range?
          params[:min_price].present? && params[:max_price].present? && 
            params[:min_price].to_f > params[:max_price].to_f
        end
        
        def find_item
          Item.search(params).first
        end
        
        def find_items
          Item.search(params)
        end
      end
    end
  end
end