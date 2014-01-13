require 'spec_helper'

describe Reward do

  before(:each) do
    @project = Project.new
    @reward = @project.rewards.build(:minimum_amount => '20', :description => 'Reward Number 1', :estimated_delivery_on => Time.current + 2.months)
  end

  it "is valid with valid attributes" do
    @reward.should be_valid
  end

  it "is invalid without minimum amount" do
    @reward.minimum_amount = nil
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

  it "is invalid if minimum amount is less than or equal to 0" do
    @reward.minimum_amount = -2
    @reward.should_not be_valid
  end

  it "is invalid if minimum amount is not an integer" do
    @reward.minimum_amount = 23.34
    @reward.should_not be_valid
  end

  it "is invalid if quantity is less than 0" do
    @reward.quantity = -2
    @reward.should_not be_valid
  end

  it "is invalid if remaining quantity is greater than quantity" do
    @reward.quantity = 35
    @reward.remaining_quantity = 40
    @reward.should_not be_valid
  end

end
