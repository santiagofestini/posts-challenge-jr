class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ArgumentError, with: :render_argument_error_response

private

  def render_unprocessable_entity_response(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_content
  end

  def render_argument_error_response(exception)
    render json: { errors: exception.message }, status: :unprocessable_content
  end
end
