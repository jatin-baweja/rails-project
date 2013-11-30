class SubscriptionsController < ApplicationController

  def weekly
    if session[:user_id]
      @email = User.find(session[:user_id]).email
    elsif session[:admin_id]
      @email = User.find(session[:admin_id]).email
    end
  end

  def index
    @email = User.find(session[:user_id]).email
    gb = Gibbon::API.new
    gb.lists.subscribe({:id => "41a18c2364", :email => {:email => @email}, :merge_vars => {:FNAME => params[:first_name], :LNAME => params[:last_name]}, :double_optin => false})
    redirect_to root_path, notice: 'You have successfully subscribed to our mailing list'
  end
end
