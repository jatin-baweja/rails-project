require 'spec_helper'

describe Message do

  before(:each) do
    @message = Message.new(:subject => 'New Subject', :content => 'This is a new message.')
  end

  it "is valid with valid attributes" do
    @message.should be_valid
  end

  it "is invalid without content" do
    @message.content = nil
    @message.should_not be_valid
  end

  it "is invalid without subject" do
    @message.subject = nil
    @message.should_not be_valid
  end

end
