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
    end
  end
end