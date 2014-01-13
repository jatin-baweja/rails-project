class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authorize
  before_action :set_i18n_locale
  #FIXME_AB: Just a thought, anonymous? also looks a candidate of helper_method. 
  helper_method :current_user, :logged_in?

  #FIXME_AB: Settings.yml should be directly in config directory, not under initializers. Also for this yml file you can write it a little better. In this yml file you are repeating many values, There is a way to make default namespace and then include it in other name space. http://stackoverflow.com/questions/6651275/what-do-the-mean-in-this-database-yml-file

  protected

    def current_user
      #FIXME_AB: It will fire "SELECT `users`.* FROM `users` WHERE `users`.`id` IS NULL AND (`users`.deleted_at IS NULL) LIMIT 1" when user is not logged in.
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def logged_in?
      !!current_user
    end

    def anonymous?
      !logged_in?
    end

    def authorize
      if anonymous?
        redirect_to login_url, notice: "Please log in"
      end
    end

    def set_i18n_locale
      if locale_available?(params[:locale])
        I18n.locale = params[:locale]
        session[:locale] = params[:locale]
      elsif session[:locale]
        I18n.locale = session[:locale]
      else
        I18n.locale = I18n.default_locale
      end
    end

    def locale_available?(locale)
      locale && I18n.available_locales.map(&:to_s).include?(locale)
    end

end
