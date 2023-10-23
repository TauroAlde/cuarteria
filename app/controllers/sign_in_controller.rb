# inside app/controllers/home_controller.rb
class SignInController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.find_by(email: params[:user][:email])

    if @user && @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id
      redirect_to root_path
    else
      flash[:alert] = "Login failed"
      redirect_to root_path
    end
  end
end
