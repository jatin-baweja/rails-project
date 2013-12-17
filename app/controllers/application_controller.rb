#FIXME_AB: There are many css and js un-used files remove them
#FIXED: Removed unused css and js files
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
      unless (logged_in?)
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
      end
    end

    #FIXME_AB: locale=en should not be in the URL as this is the default. also every url has locale=en. Once the language is set, you should save this in session and use from there.. I mean use locale in url for changing language. Once it is changed save it in session.
    #FIXED: Removed locale from default url options

end
