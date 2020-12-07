class ApplicationController < ActionController::API
  rescue_from SKAuthenticationError, with: :rescue_sk_authentication_error
  rescue_from ActiveRecord::RecordInvalid, with: :rescue_active_record_record_invalid

  def set_current_user_from_jwt
    auth_header = request.headers["Authorization"]
    raise SKAuthenticationError.new("Not logged in") if auth_header.blank?
    auth_split = auth_header.split(" ")
    raise SKAuthenticationError.new("Not logged in") if auth_split.first != "Bearer"
    auth_jwt = auth_split.last
    key = Rails.application.credentials.secret_key_base
    decoded = JWT.decode auth_jwt, key, 'HS256'
    payload = decoded.first
    if payload.blank? || payload["jti"].blank?
      raise SKAuthenticationError.new("Not logged in")
    end
    @current_user = User.find_by_jti(payload["jti"])
    raise SKAuthenticationError.new("Not logged in") if @current_user.blank?
  end

  private
  def rescue_sk_authentication_error(err)
    render json: { success: false, type: err.class.to_s, error: err },
         status: :unauthorized and return
  end

  def rescue_active_record_record_invalid(err)
    render json: { success: false, type: err.class.to_s, error: err.errors.as_json },
         status: :bad_request
  end
end
