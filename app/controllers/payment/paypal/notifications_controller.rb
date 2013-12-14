class Payment::Paypal::NotificationsController < ApplicationController
  protect_from_forgery :except => [:create]
  skip_before_action :authorize, only: [:create]

  def create
    Transaction.create(pledge_id: params[:invoice], status: 'uncharged', payment_mode: 'paypal', transaction_id: params[:txn_id])
    # Rails.logger.debug("\n\n\n\nParameters: #{params}\n\n\n\nInvoice: #{params[:invoice]}\n\n\n\n\nPayment Status: #{params[:payment_status]}\n\n\n\n\nTransaction Id: #{params[:txn_id]}\n\n\n\n")
    render :nothing => true
  end

end
