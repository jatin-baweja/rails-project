require 'spec_helper'

describe RequestedReward do

  before(:each) do
    @requested_reward = RequestedReward.new(quantity: 20)
    @requested_reward.pledge = FactoryGirl.create(:pledge, amount: 300)
    @requested_reward.reward = FactoryGirl.create(:reward, minimum_amount: 10, description: "Example", estimated_delivery_on: 2.months.from_now, quantity: 100, remaining_quantity: 40)
    @requested_reward.stub(:requested_rewards_total).and_return(true)
  end

  it "is valid with valid attributes" do
    @requested_reward.should be_valid
  end

  it "is invalid without reward" do
    @requested_reward.reward_id = nil
    @requested_reward.should_not be_valid
  end

  it "is invalid without pledge" do
    @requested_reward.pledge_id = nil
    @requested_reward.should_not be_valid
  end

end
