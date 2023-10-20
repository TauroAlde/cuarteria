class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save!
      flash[:notice] = 'User created successfully'
      redirect_to users_path
    else
      flash[:alert] = 'User not created'
      redirect_to sign_in_index_path
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
