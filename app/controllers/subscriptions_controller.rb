class SubscriptionsController < ApplicationController
  skip_before_action :authorize, only: [:weekly]

  def weekly
    if logged_in?
      @email = current_user.email
    end
  end

  def index
    if params[:email].match(REGEX_PATTERN[:email])
      begin
        gb = Gibbon::API.new
        #FIXME_AB: WEEKLY_SUBSCRIPTION_LIST_ID should be coming from environment based hash like paypal. Remember?
        #FIXED: Created hash and method similar to paypal
        gb.lists.subscribe({:id => mailchimp_weekly_subscription_list_id, :email => {:email => params[:email]}, :merge_vars => {:FNAME => params[:first_name], :LNAME => params[:last_name]}, :double_optin => false})
        redirect_to root_path, notice: 'You have successfully subscribed to our mailing list'
      rescue Gibbon::MailChimpError
        redirect_to root_path, alert: 'Sorry, we cannot save your details presently. Please try after some time.'
      end
    else
      flash[:alert] = 'Email format incorrect'
      #FIXME_AB: 'weekly' => :weekly. string vs symbol
      #FIXED: Changed to symbol
      redirect_to action: :weekly
    end
  end
end
