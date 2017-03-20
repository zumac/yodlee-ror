class UsersController < ApplicationController
  before_action :doorkeeper_authorize!
  respond_to :json
  def me
    success_response = {
      success: true,
      message: "Login successful"
    }
    fail_response = {
      success: false,
      message: "Not authorized"
    }
    user = User.find(doorkeeper_token.resource_owner_id)
    if user.present?
      user_response = success_response
      user_response[:user] = user
      sign_in user
    else
      user_response = fail_response
    end
    render json: user_response
  end

end
