module V1
  class AuthsController < ApplicationController
    skip_before_action :authenticate_user

    def create
      token_command = AuthenticateUserCommand.call(*auth_params.slice(:email, :password).values)

      if token_command.success?
        render json: { token: token_command.result }, status: :ok
      else
        render json: { error: token_command.errors }, status: :unauthorized
      end
    end

    def register
      @user = User.new(auth_params)

      if @user.save
        render json: @user, status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    private

    def auth_params
      params.require(:auth).permit(:email, :password, :display_name)
    end
  end
end
