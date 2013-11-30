class Payment::Stripe::ChargesController < ApplicationController

  def new_card
    @project = Project.find(params[:project])
    @pledge = Pledge.find(params[:pledge])
    @user = User.find(session[:user_id])
    if !@user.account.nil?
      customer = Stripe::Customer.retrieve(@user.account.customer_id)
      @cust_card = customer.cards.retrieve(@user.account.card_id)
    end
  end

  def create_card

    user = User.find(session[:user_id])
    email = user.email

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

      user.create_account(customer_id: customer.id, card_id: customer.default_card)
    end
    pledge = Pledge.find(params[:pledge_id])
    pledge.create_transaction(status: 'uncharged', payment_mode: 'stripe')
    Delayed::Job.enqueue(PledgeNotifierJob.new(pledge, pledge.project, pledge.user))

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to root_path
  end

  def charge_card
    @project = Project.find(params[:project])
    @pledges = @project.pledges
    @pledges.each do |pledge|
      user_to_charge = pledge.user
      if(!user_to_charge.account.nil? && !pledge.transaction.nil? && pledge.transaction.status != 'charged')
        amount_to_charge = pledge.amount
        amount_to_charge = amount_to_charge * 100    # To represent in cents
        cust_token = user_to_charge.stripe_account.customer_token
        charge = Stripe::Charge.create(
          :customer    => cust_token,
          :amount      => amount_to_charge,
          :description => 'Project Pledge customer',
          :currency    => 'usd'
        )
        pledge.create_transaction(status: 'charged', transaction_id: charge.id)
      end
    end
  end

end
