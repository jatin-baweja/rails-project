require 'spec_helper'

describe User do

  before(:each) do
    @user = User.new(:name => 'Xyz', :email => 'xyz@abc.com', :email_confirmation => 'xyz@abc.com', :password => 'abcdef', :password_confirmation => 'abcdef', admin: false)
  end

  it "is valid with valid attributes" do
    @user.should be_valid
  end

  it "is invalid without an email" do
    @user.email = nil
    @user.should_not be_valid
  end

  it "is invalid without an email_confirmation" do
    @user.email_confirmation = nil
    @user.should_not be_valid
  end

  it "is invalid without an email match" do
    @user.email = 'rbz@nyz.com'
    @user.should_not be_valid
  end

  it "is invalid without a name" do
    @user.name = nil
    @user.should_not be_valid
  end

  it "is invalid without a password" do
    @user.password = nil
    @user.password_confirmation = nil
    @user.should_not be_valid
  end

  it "is invalid without a password match" do
    @user.password = 'rbzm'
    @user.should_not be_valid
  end

end
