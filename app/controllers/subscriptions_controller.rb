class SubscriptionsController < ApplicationController

  def weekly
    #FIXME_AB: This is a very bad way of doing it. What if we start saving user email in session instead of user_id. Please think of a better approach
    if session[:user_id]
      @email = User.find(session[:user_id]).email
    elsif session[:admin_id]
      @email = User.find(session[:admin_id]).email
    end
  end

  def index
    @email = User.find(session[:user_id]).email
    #FIXME_AB: What if any exception occurs. Lets say timeout or anything. How would you ensure that you display success message only after it was successful
    gb = Gibbon::API.new
    #FIXME_AB: shouldn't this id be a constant hash based on environment. What if the subscription list id change?
    gb.lists.subscribe({:id => "41a18c2364", :email => {:email => @email}, :merge_vars => {:FNAME => params[:first_name], :LNAME => params[:last_name]}, :double_optin => false})
    redirect_to root_path, notice: 'You have successfully subscribed to our mailing list'
  end
end
