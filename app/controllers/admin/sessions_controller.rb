class Admin::SessionsController < ApplicationController
  before_action :admin_authorize
  skip_before_action :admin_authorize, only: [:new, :create]
  skip_before_action :authorize

  def new
  end

  def create
    user = Admin.find_by email: params[:email]
    if user and user.authenticate(params[:password])
      session[:admin_id] = user.id
      redirect_to admin_root_url
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
    unless Admin.find_by id: session[:admin_id]
      redirect_to admin_login_url, notice: "Please log in"
    end
  end

end
