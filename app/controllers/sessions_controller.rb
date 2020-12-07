class SessionsController < ApplicationController
  before_action :set_current_user_from_jwt, only: [:me, :sign_out]

  def sign_up
    user = User.new
    user.email = params[:user][:email]
    user.first_name = params[:user][:first_name]
    user.last_name = params[:user][:last_name]
    user.password = params[:user][:password]
    user.password_confirmation = params[:user][:password_confirmation]
    if user.save
      render json: { success: true }, status: :created
    else
      render json: { success: false, errors: user.errors.as_json },
           status: :bad_request
    end
  end

  def sign_in
    user = User.find_by_email(params[:user][:email])
    if user.valid_password?(params[:user][:password])
      render json: { success: true, jwt: user.jwt },
           status: :created
    else
      render json: { success: false }, status: :unauthorized
    end
  end

  def me
    render json: { success: true, user: @current_user.as_json }
  end

  def sign_out
    @current_user.generate_jti(true)
    @current_user.save
    render json: { success: true }
  end
end
