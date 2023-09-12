class ApplicationController < ActionController::Base
  private

  def with_error_handling
    error = nil
    body = begin
      yield
    rescue Exception => e
      error = e.message
    end
    render status: :ok, json: error.present? ? { status: false, error: error } : body
  end

  def authenticate_request
    @current_user = User.auth_by_token(request.headers)
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end
end
