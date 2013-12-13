class SessionsController < ApplicationController
  skip_before_action :authorize
  def new
  end

  def create
    #FIXME_AB: good practice to have parenthesis around arguments
    #FIXED: parenthesis added
    user = User.find_by(email: params[:email])
    if user and user.authenticate(params[:password])
      session[:user_id] = user.id
      #FIXME_AB: I think we don't need to save name in session
      #FIXED: removed name from session
      if current_user.admin?
        redirect_to admin_projects_pending_for_approval_url
      else
        redirect_to root_url
      end
    else
      redirect_to login_url, notice: "Invalid user/password combination"
    end
  end

  def destroy
    #FIXME_AB: This is not the right way to logout any user. 
    #FIXED: Clearing entire session instead of specific keys
    reset_session
    redirect_to root_url, notice: "You have been logged out"
  end

  def facebook_create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_url
  end

end
