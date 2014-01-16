class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user and user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to_admin_or_home
    else
      flash.now[:alert] = "Invalid email/password"
      render action: :new
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "You have been logged out"
  end

  def facebook_create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_path
  end

  private

    def redirect_to_admin_or_home
      if current_user.admin?
        redirect_to admin_projects_path
      else
        redirect_to root_path
      end
    end

end
