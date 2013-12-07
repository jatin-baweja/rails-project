class SubscriptionsController < ApplicationController
  skip_before_action :authorize, only: [:weekly]

  def weekly
    #FIXME_AB: This is a very bad way of doing it. What if we start saving user email in session instead of user_id. Please think of a better approach
    #FIXED: current_user helper_method for views and controllers
    if logged_in?
      @email = current_user.email
    end
  end

  def index
    if params[:email].match(REGEX_PATTERN[:email])
      begin
        #FIXME_AB: What if any exception occurs. Lets say timeout or anything. How would you ensure that you display success message only after it was successful
        #FIXED: Added Exception Handling
        gb = Gibbon::API.new
        #FIXME_AB: shouldn't this id be a constant hash based on environment. What if the subscription list id change?
        #FIXED: Constant Added to MailChimp Initializer
        gb.lists.subscribe({:id => WEEKLY_SUBSCRIPTION_LIST_ID, :email => {:email => params[:email]}, :merge_vars => {:FNAME => params[:first_name], :LNAME => params[:last_name]}, :double_optin => false})
        redirect_to root_path, notice: 'You have successfully subscribed to our mailing list'
      rescue Gibbon::MailChimpError
        redirect_to root_path, alert: 'Sorry, we cannot save your details presently. Please try after some time.'
      end
    else
      flash[:alert] = 'Email format incorrect'
      redirect_to action: 'weekly'
    end
  end
end
