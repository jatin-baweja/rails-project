class SessionsController < ApplicationController
  #FIXME_AB: I am not sure but destroy/logout action should authorize user, what are your thoughts
  #FIXED: It should not authorize as the person might have multiple tabs opened and might logout from both, but on 2nd attempt would not see the successful logout message.
  skip_before_action :authorize

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user and user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to_admin_or_home
    else
      #FIXME_AB: instead of redirecting back to login page, you can render the login page here itself. It would save another request. Check log, when you submit empty login form
      #FIXED: Changed redirect_to to render
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
        #FIXME_AB: Within the app, I prefer to use _path methods instead of _url methods, because they are relative to the current page.
        #FIXED: Changed _url to _path
        redirect_to admin_projects_path
      else
        redirect_to root_path
      end
    end

end
