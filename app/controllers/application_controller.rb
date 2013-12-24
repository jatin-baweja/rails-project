class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authorize
  before_action :set_i18n_locale
  helper_method :current_user, :logged_in?

  protected

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def logged_in?
      !!current_user
    end

    def anonymous?
      !logged_in?
    end

    def authorize
      #FIXME_AB: You have anonymous? so You can use that here :)
      #FIXED: using anonymous?
      if anonymous?
        redirect_to login_url, notice: "Please log in"
      end
    end

    def set_i18n_locale
      if params[:locale]
        if I18n.available_locales.map(&:to_s).include?(params[:locale])
          I18n.locale = params[:locale]
          session[:locale] = params[:locale]
        else
          flash.now[:notice] = "#{params[:locale]} translation not available"
          logger.error flash.now[:notice]
        end
      elsif session[:locale]
        I18n.locale = session[:locale]
      else
        I18n.locale = I18n.default_locale
      end
      #FIXME_AB: what if locale is not in params and not in session too
      #FIXED: Setting to I18n.default_locale if locale not in params or session
    end

end
