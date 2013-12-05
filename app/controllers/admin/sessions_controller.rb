#FIXME_AB: You are inheriting every controller from this controller so should be named as something like Admin::BaseController or Admin::ApplicationController. Infact you should be using same form for user and admin login
class Admin::SessionsController < ApplicationController
  before_action :admin_authorize
  skip_before_action :admin_authorize, only: [:new, :create]
  skip_before_action :authorize

  def new
  end

  def create
    user = User.where(admin: true).find_by email: params[:email]
    if user and user.authenticate(params[:password])
      session[:admin_id] = user.id
      redirect_to admin_projects_pending_for_approval_url
    else
      redirect_to admin_login_url, notice: "Invalid user/password combination"
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to root_url, notice: "You have been logged out"
  end

  private

  def admin_authorize
    #FIXME_AB: what about having something like current_user.admin?
    unless User.where(admin: true).find_by id: session[:admin_id]
      redirect_to admin_login_url, notice: "Please log in"
    end
  end

end
