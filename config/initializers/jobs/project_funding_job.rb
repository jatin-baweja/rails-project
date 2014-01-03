class ProjectFundingJob < Struct.new(:project)

  #FIXME_AB: We can improve this method.
  #FIXED: Added callbacks and hooks
  def perform
    pledges = project.pledges
    if pledges.sum(:amount) >= project.goal
      pledges.each do |pledge|
        charge_card(pledge)
      end
      project.completely_funded!
    else
      project.failed_funding_goal!
    end # if project goal reached or not
  end

  def enqueue(job)
    unless project.approved?
      raise "Unapproved Project being added for funding!"
    end
  end

  def charge_card(pledge)
    user_to_charge = pledge.user
    if(user_to_charge.account.present? && pledge.transaction.present? && pledge.transaction.status != 'charged')
      amount_to_charge = pledge.amount * 100    # To represent in cents
      cust_token = user_to_charge.account.customer_id
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
