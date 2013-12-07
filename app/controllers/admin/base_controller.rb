#FIXME_AB: You are inheriting every controller from this controller so should be named as something like Admin::BaseController or Admin::ApplicationController. Infact you should be using same form for user and admin login
#FIXED: Changed controller name, moved admin login to user login
class Admin::BaseController < ApplicationController
  before_action :admin_authorize
  skip_before_action :authorize

  private

  def admin_authorize
    #FIXME_AB: what about having something like current_user.admin?
    #FIXED: added current_user method
    unless (logged_in? && current_user.admin?)
      redirect_to admin_login_url, notice: "Please log in"
    end
  end

end
