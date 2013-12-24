class PledgesController < ApplicationController
  include Projects::Setter

  before_action :set_project
  before_action :validate_not_owner

  def new
  end

  def create
    if !blank_rewards?
      @pledge = @project.pledges.build(pledge_params)
      @pledge.user = current_user
      @pledge.save_with_associated_rewards(params[:rewards])
      if params[:payment_mode] == "Paypal"
        redirect_to @project.paypal_url(project_url(@project), @pledge)
      else
        redirect_to payment_stripe_charges_new_card_url(project: @project.id, pledge: @pledge.id)
      end
    end
  rescue ActiveRecord::RecordInvalid
    render action: :new
  rescue ActiveRecord::RecordNotSaved
    render action: :new
  end

  private

    def pledge_params
      params.require(:pledge).permit(:amount, :requested_rewards_attributes => [:id])
    end

    def validate_not_owner
      if(@project.owner?(current_user))
        redirect_to project_path(@project), notice: "You cannot pledge for your own project"
      end
    end

    def blank_rewards?
      reward_present = {}
      if params[:rewards]
        params[:rewards].each do |key, val|
          reward_present[key] = true
          reward_present[key] = false if !val.key?("id")
          val.each do |attr_key, attr_val|
            reward_present[key] = false if attr_val.blank?
          end
        end
        if reward_present.any? { |key, value| value == false }
          render action: :new, alert: "Please don't leave empty rewards"
        end
      end
      reward_present.any? { |key, value| value == false }
    end

end
