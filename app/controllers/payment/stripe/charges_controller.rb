class Payment::Stripe::ChargesController < ApplicationController

  def new_card
    @project = Project.find(params[:project])
    @pledge = Pledge.find(params[:pledge])
    @user = current_user
    if @user.account.present?
      customer = Stripe::Customer.retrieve(@user.account.customer_id)
      @cust_card = customer.cards.retrieve(@user.account.card_id)
    end
  end

  def create_card

    @user = current_user
    email = @user.email

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
    @pledge = Pledge.find(params[:pledge_id])
    @project = @pledge.project
    @pledge.create_transaction(status: 'uncharged', payment_mode: 'stripe')
    Delayed::Job.enqueue(PledgeNotifierJob.new(@pledge, @project, @user))

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to root_path
  end

end
