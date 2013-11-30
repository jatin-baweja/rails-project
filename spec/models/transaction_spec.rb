require 'spec_helper'

describe Transaction do

  before(:each) do
    @transaction = Transaction.new(:transaction_id => "tran_122133ede", :payment_mode => 'Stripe', :status => 'charged')
  end

  it "is valid with valid attributes" do
    @transaction.should be_valid
  end

  it "is invalid without payment mode" do
    @transaction.payment_mode = nil
    @transaction.should_not be_valid
  end

  it "is invalid without status" do
    @transaction.status = nil
    @transaction.should_not be_valid
  end
end
