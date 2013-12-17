class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  #FIXME_AB: Empty signup form submitted. No error was shown
  def create
    user = User.find_by(email: params[:email])
    if user and user.authenticate(params[:password])
      session[:user_id] = user.id
      #FIXME_AB: One other way(how I do this is): redirect_to_admin_or_home
      #FIXED: Made a private method
      redirect_to_admin_or_home
    else
      redirect_to login_url, notice: "Invalid user/password combination"
    end
  end

  def destroy
    reset_session
    redirect_to root_url, notice: "You have been logged out"
  end

  def facebook_create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_url
  end

  private

    def redirect_to_admin_or_home
      if current_user.admin?
        redirect_to admin_projects_pending_for_approval_url
      else
        redirect_to root_url
      end
    end

end
