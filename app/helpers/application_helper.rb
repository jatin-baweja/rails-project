module ApplicationHelper

  def current_user
    session[:user_id]
  end

  def user_signed_in?
    session[:user_id] ? true : false
  end

  def admin_signed_in?
    session[:admin_id] ? true : false
  end

end
