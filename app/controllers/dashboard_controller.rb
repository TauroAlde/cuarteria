class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    #redirect_to consultations_path if current_user.admin?
  end

  private

end
