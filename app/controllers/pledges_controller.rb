class PledgesController < ApplicationController
  include Projects::Callbacks
  require 'paypal'

  before_action :set_project
  before_action :validate_not_owner
  before_action :check_blank_rewards, only: [:create]

  def new
  end

  def create
    @pledge = @project.pledges.build(pledge_params)
    @pledge.user = current_user
    @pledge.save_with_associated_rewards
    if params[:payment_mode] == "Paypal"
      redirect_to Paypal.url(@project, project_url(@project), @pledge)
    else
      redirect_to payment_stripe_charges_new_card_path(project: @project.id, pledge: @pledge.id)
    end
  rescue ActiveRecord::RecordInvalid
    render action: :new
  rescue ActiveRecord::RecordNotSaved
    render action: :new
  end

  private

    def pledge_params
      params.require(:pledge).permit(:amount, :requested_rewards_attributes => [:id, :reward_id, :quantity, :_destroy])
    end

    def validate_not_owner
      if(@project.owner?(current_user))
        redirect_to project_path(@project), notice: "You cannot pledge for your own project"
      end
    end

    def check_blank_rewards
      if blank_rewards?
        flash.now[:alert] = "Please check the reward checkbox and fill quantity to select rewards."
        @pledge = @project.pledges.build(pledge_params)
        render action: :new
      end
    end

    def blank_rewards?
      reward_present = {}
      params[:pledge][:requested_rewards_attributes].each do |key, val|
        reward_present[key] = true
        val.each do |attr_key, attr_val|
          reward_present[key] = false if attr_val.blank?
        end
        if (val.key?("reward_id") && !reward_present[key]) || (!val.key?("reward_id") && reward_present[key])
          reward_present[key] = false
        else
          reward_present[key] = true
        end
      end
      reward_present.any? { |key, value| value == false }
    end

end
