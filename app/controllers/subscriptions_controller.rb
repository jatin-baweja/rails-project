class SubscriptionsController < ApplicationController
  def daily
  end

  def weekly
    @email = User.find(session[:user_id]).email
  end

  def monthly
  end

  def index
    @email = User.find(session[:user_id]).email
    gb = Gibbon::API.new
    gb.lists.subscribe({:id => "41a18c2364", :email => {:email => @email}, :merge_vars => {:FNAME => params[:first_name], :LNAME => params[:last_name]}, :double_optin => false})
    redirect_to root_path, notice: 'You have successfully subscribed to our mailing list'
  end
end
