class Api::V1::SessionsController < ApplicationController
  def create
    user_password = session_params[:password]
    user_email = session_params[:email]
    user = User.find_by(email: user_email) if user_email.present?

    if user && user.valid_password?(user_password)
      sign_in user, store: false
      user.generate_authentication_token!
      user.save
      render json: user, status: 200, location: [:api, user]
    else
      render json: { errors: "Invalid email or password" }, status: 422
    end
  end

  def destroy
    user = User.find_by(auth_token: params[:id])
    if user
      user.generate_authentication_token!
      user.save
    end
    head 204
  end

private

  def session_params
    params.require(:session).permit(:password, :email)
  end

end
