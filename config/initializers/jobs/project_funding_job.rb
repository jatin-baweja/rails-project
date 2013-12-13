class ProjectFundingJob < Struct.new(:project)

  def perform
    if project.approved?
      @pledges = project.pledges
      if @pledges.sum(:amount) >= project.goal
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
            PledgeNotifier.charged(user_to_charge, pledge.amount, project).deliver
          end
        end # each pledge
        project.completely_funded!
        ProjectStatusNotifier.funded(project).deliver
      else
        project.failed_funding_goal!
        ProjectStatusNotifier.failed(project).deliver
      end # if project goal reached or not
    end # if project approved
  end

end
