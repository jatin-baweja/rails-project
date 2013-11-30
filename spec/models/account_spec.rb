require 'spec_helper'

describe Account do

  before(:each) do
    @account = Account.new(:customer_id => "cus_122133ede", :card_id => "card_13ab34f4", :user_id => 12)
  end

  it "is valid with valid attributes" do
    @account.should be_valid
  end

  it "is invalid without customer id" do
    @account.customer_id = nil
    @account.should_not be_valid
  end

  it "is invalid without card id" do
    @account.card_id = nil
    @account.should_not be_valid
  end

  it "is invalid without user id" do
    @account.user_id = nil
    @account.should_not be_valid
  end

end
