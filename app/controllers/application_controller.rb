class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authorize
  before_action :set_i18n_locale_from_params

  protected

    def authorize
      #FIXME_AB: Why we are distinguishing user and admin by user_id and admin_id in session. admin is a type of user so you should only save user_id in session. 
      unless (User.find_by(id: session[:user_id]) || User.find_by(id: session[:admin_id]))
        redirect_to login_url, notice: "Please log in"
      end
    end

    def set_i18n_locale_from_params
      if params[:locale]
        if I18n.available_locales.map(&:to_s).include?(params[:locale])
          I18n.locale = params[:locale]
        else
          #FIXME_AB: assignment should be in the same line
          flash.now[:notice] = 
            "#{params[:locale]} translation not available"
          logger.error flash.now[:notice]
        end
      end
    end

    def default_url_options
      { locale: I18n.locale }
    end

end
