class Payment::Paypal::NotificationsController < ApplicationController
  protect_from_forgery :except => [:create]
  skip_before_action :authorize, only: [:create]

  def create
    Transaction.create(pledge_id: params[:invoice], status: 'authorized', payment_mode: 'paypal', transaction_id: params[:txn_id])
    render :nothing => true
  end

end
