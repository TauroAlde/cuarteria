class DashboardController < ApplicationController
  def index
    return render 'dashboard/admin' if current_user.role

    render 'dasboard'
  end
end
