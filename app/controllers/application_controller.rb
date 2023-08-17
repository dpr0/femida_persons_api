class ApplicationController < ActionController::Base
  def with_error_handling
    error = nil
    body = begin
             yield
           rescue Exception => e
             error = e.message
           end
    render status: :ok, json: error.present? ? { status: false, error: error } : body
  end
end
