class UserProfilesController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    user = User.find(params[:id])

    if user
      user.update(name: user_profiles_params['name'], email: user_profiles_params['email'])

      flash[:success] = 'Se ha actualziado correctamente'
    else
      flash[:error] = 'No se ha logrado actualizar la informacion del perfil'
    end
  end

  private

  def user_profiles_params
    params.require(:user).permit(:name, :email)
  end
end
