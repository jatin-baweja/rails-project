require 'spec_helper'

describe RequestedReward do

  before(:each) do
    @project = Project.new
    @pledge = @project.pledges.build
    @requested_reward = @pledge.requested_rewards.build
    @requested_reward.reward_id = 2;
    @requested_reward.pledge_id = 3;
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
