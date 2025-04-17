module Api
  module V1
    class BaseController < ApplicationController # keep logic seperate based on concerns nice n dry
      rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity_response

      private

      def not_found_response(exception)
        render json: { 
          message: "your query could not be completed",
          errors: [exception.message]
        }, status: :not_found
      end

      def unprocessable_entity_response(exception)
        render json: { 
          message: "your query could not be completed",
          errors: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end
      
      def render_error(message)
        render json: { 
          message: "your query could not be completed", 
          errors: [message] 
        }, status: :bad_request
      end
      
      def min_price_exceeds_max_price?
        params[:min_price].present? && params[:max_price].present? && 
          params[:min_price].to_f > params[:max_price].to_f
      end

      def negative_price_params?
        (params[:min_price].present? && params[:min_price].to_f < 0) || 
        (params[:max_price].present? && params[:max_price].to_f < 0)
      end
      
      def invalid_parameter_combinations?
        params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
      end
      
      def all_params_blank?(param_keys)
        param_keys.all? { |key| params[key].blank? }
      end
    end
  end
end