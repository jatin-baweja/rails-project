class Admin::BaseController < ApplicationController
  before_action :admin_authorize
  skip_before_action :authorize

  private

  def admin_authorize
    unless (logged_in? && current_user.admin?)
      redirect_to login_url, notice: "Please log in"
    end
  end

end
