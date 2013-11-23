require 'spec_helper'

describe Pledge do

  before(:each) do
    @pledge = Pledge.new(:amount => 25)
  end

  it "is valid with valid attributes" do
    @pledge.should be_valid
  end

  it "is invalid without amount" do
    @pledge.amount = nil
    @pledge.should_not be_valid
  end

  it "is invalid with amount not an integer" do
    @pledge.amount = 23.45
    @pledge.should_not be_valid
  end

  it "is invalid with amount less than or equal to 0" do
    @pledge.amount = -1
    @pledge.should_not be_valid
  end

end
