class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authorize
  before_action :set_i18n_locale
  helper_method :current_user, :logged_in?


  protected

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def logged_in?
      !!current_user
    end

    def anonymous?
      !logged_in?
    end

    def authorize
      if anonymous?
        redirect_to login_path, notice: "Please log in"
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
