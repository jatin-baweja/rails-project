require 'spec_helper'

describe Location do

  before(:each) do
    @location = Location.new(:name => "New Delhi")
  end

  it "is valid with valid attributes" do
    @location.should be_valid
  end

  it "is invalid without a name" do
    @location.name = nil
    @location.should_not be_valid
  end

end
