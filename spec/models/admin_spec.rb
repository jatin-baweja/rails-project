require 'spec_helper'

describe Admin do
  before(:each) do
    @admin = Admin.new(:email => 'xyz@abc.com', :email_confirmation => 'xyz@abc.com', :password => 'abcd', :password_confirmation => 'abcd')
  end

  it "is valid with valid attributes" do
    @admin.should be_valid
  end

  it "is invalid without an email" do
    @admin.email = nil
    @admin.should_not be_valid
  end

  it "is invalid without an email_confirmation" do
    @admin.email_confirmation = nil
    @admin.should_not be_valid
  end

  it "is invalid without an email match" do
    @admin.email = 'rbz@nyz.com'
    @admin.should_not be_valid
  end

  it "is invalid without a password" do
    @admin.password = nil
    @admin.password_confirmation = nil
    @admin.should_not be_valid
  end

  it "is invalid without a password match" do
    @admin.password = 'rbzm'
    @admin.should_not be_valid
  end

end
