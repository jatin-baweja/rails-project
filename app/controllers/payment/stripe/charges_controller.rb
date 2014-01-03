class Payment::Stripe::ChargesController < ApplicationController

  def new_card
    @project = Project.find_by(id: params[:project])
    @pledge = Pledge.find_by(id: params[:pledge])
    @user = current_user
    if @user.account.present?
      customer = Stripe::Customer.retrieve(@user.account.customer_id)
      @cust_card = customer.cards.retrieve(@user.account.card_id)
    end
  end

  def create_card
    email = current_user.email
    if params[:pay_with_existing_card] != "1"
      customer = Stripe::Customer.create(
        :email => email,
        :card  => {
          :number => params[:card_number],
          :exp_month => params[:expiry_date]["(2i)"],
          :exp_year => params[:expiry_date]["(1i)"],
          :cvc => params[:cvc_number],
          :name => params[:name_on_card]
        }
      )
      @user.create_account(customer_id: customer.id, card_id: customer.default_card)
    end
    pledge = Pledge.find(params[:pledge_id])
    pledge.create_transaction(status: 'uncharged', payment_mode: 'stripe')
    redirect_to project_path(pledge.project), notice: 'Your card has been successfully stored'

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to root_path
  end

end
