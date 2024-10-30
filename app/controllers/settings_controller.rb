class SettingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @settings = current_user.settings
  end

  def new
    @setting = Setting.new
  end

  def create
    binding.pry
    @setting = Setting.new(setting_params)
    @setting.user = current_user
    if @setting.save
      redirect_to settings_path, notice: 'Setting was successfully created.'
    else
      render :new
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:app_name, :api_key, :secret_key, :token)
  end
end
