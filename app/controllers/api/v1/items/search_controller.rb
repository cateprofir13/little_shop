module Api
  module V1
    module Items
      class SearchController < BaseController
        def show
          if invalid_parameter_combinations?
            render json: { 
              message: "your query could not be completed", 
              errors: ["Cannot combine name with price parameters"] 
            }, status: :bad_request
            return
          end

          if negative_price_params?
            render json: { 
              message: "your query could not be completed",
              errors: ["Price parameters cannot be negative"] 
            }, status: :bad_request
            return
          end
          
          if all_params_blank?
            render json: { 
              message: "your query could not be completed", 
              errors: ["No valid search parameter"] 
            }, status: :bad_request
            return
          end
          
          item = find_item
          
          if item.nil?
            render json: { data: {} }
          else
            render json: ItemSerializer.new(item)
          end
        end

        def index
          if invalid_parameter_combinations?
            render json: { 
              message: "your query could not be completed", 
              errors: ["Cannot combine name with price parameters"] 
            }, status: :bad_request
            return
          end

          if negative_price_params?
            render json: { 
              message: "your query could not be completed",
              errors: ["Price parameters cannot be negative"] 
            }, status: :bad_request
            return
          end
          
          if all_params_blank?
            render json: { 
              message: "your query could not be completed", 
              errors: ["No valid search parameter"] 
            }, status: :bad_request
            return
          end
          
          items = find_items
          
          render json: ItemSerializer.new(items)
        end
        
        private
        
        def search_params
          params.permit(:name, :min_price, :max_price)
        end

        def all_params_blank?
          params[:name].blank? && params[:min_price].blank? && params[:max_price].blank?
        end

        def invalid_parameter_combinations?
          params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
        end

        def negative_price_params?
          (params[:min_price].present? && params[:min_price].to_f < 0) || 
          (params[:max_price].present? && params[:max_price].to_f < 0)
        end
        
        def find_item
          if params[:name].present?
            Item.where('lower(name) ILIKE ?', "%#{params[:name].downcase}%").first
          elsif params[:min_price].present? && params[:max_price].present?
            Item.where('unit_price >= ? AND unit_price <= ?', params[:min_price], params[:max_price])
               .order(unit_price: :asc).first
          elsif params[:min_price].present?
            Item.where('unit_price >= ?', params[:min_price])
               .order(unit_price: :asc).first
          elsif params[:max_price].present?
            Item.where('unit_price <= ?', params[:max_price])
               .order(unit_price: :asc).first
          end
        end
        
        def find_items
          if params[:name].present?
            Item.where('lower(name) ILIKE ?', "%#{params[:name].downcase}%")
          elsif params[:min_price].present? && params[:max_price].present?
            Item.where('unit_price >= ? AND unit_price <= ?', params[:min_price], params[:max_price])
          elsif params[:min_price].present?
            Item.where('unit_price >= ?', params[:min_price])
          elsif params[:max_price].present?
            Item.where('unit_price <= ?', params[:max_price])
          else
            []
          end
        end
      end
    end
  end
end