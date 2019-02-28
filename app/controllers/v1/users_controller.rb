module V1
  class UsersController < ApplicationController
    before_action :set_user, only: [:show, :update, :destroy]

    # GET /users
    def index
      begin
        @users = current_user&.admin? ? User.all : [User.find(current_user&.id)]
      rescue ActiveRecord::RecordNotFound
        @users = []
      end

      render json: @users
    end

    # GET /users/1
    def show
      # set_user(current_user&.id)
      render json: { display_name: @user[:display_name] } #@user
    end

    # POST /users
    # def create
    #   authorize! :create
    #   @user = User.new(user_params)
    #
    #   if @user.save
    #     render json: @user, status: :created
    #   else
    #     render json: @user.errors, status: :unprocessable_entity
    #   end
    # end

    # PATCH/PUT /users/1
    def update
      authorize! :update, @user
      if @user.update(user_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    # DELETE /users/1
    def destroy
      authorize! :destroy, @user
      @user.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user(id=params[:id])
        @user = User.find(id)
      end

      # Only allow a trusted parameter "white list" through.
      def user_params
        params.require(:user).permit(:email, :password_digest, :display_name, :api_key, :admin)
      end
  end
end
