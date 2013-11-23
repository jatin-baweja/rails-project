require 'spec_helper'

describe Reward do

  before(:each) do
    @project = Project.new
    @reward = @project.rewards.build(:minimum => '20', :description => 'Reward Number 1', :estimated_delivery_on => Time.now + 2.months)
  end

  it "is valid with valid attributes" do
    @reward.should be_valid
  end

  it "is invalid without minimum" do
    @reward.minimum = nil
    @reward.should_not be_valid
  end

  it "is invalid without description" do
    @reward.description = nil
    @reward.should_not be_valid
  end

  it "is invalid without estimated_delivery_on" do
    @reward.estimated_delivery_on = nil
    @reward.should_not be_valid
  end

  it "is invalid if minimum is less than or equal to 0" do
    @reward.minimum = -2
    @reward.should_not be_valid
  end

  it "is invalid if minimum is not an integer" do
    @reward.minimum = 23.34
    @reward.should_not be_valid
  end

end
