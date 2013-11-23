require 'spec_helper'

describe SubscriptionsController do

  describe "GET 'daily'" do
    it "returns http success" do
      get 'daily'
      response.should be_success
    end
  end

  describe "GET 'weekly'" do
    it "returns http success" do
      get 'weekly'
      response.should be_success
    end
  end

  describe "GET 'monthly'" do
    it "returns http success" do
      get 'monthly'
      response.should be_success
    end
  end

end
